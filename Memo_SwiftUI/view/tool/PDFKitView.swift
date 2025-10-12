//
//  PDFKitView.swift
//  Memo_SwiftUI
//
//  Created by 하고 싶은 걸 하고 살자 on 10/11/25.
//
import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    let url: URL
    @Binding var mode: PDFToolMode
    @Binding var lastSavedURL: URL?
    @Binding var memoText: String
    func makeUIView(context: Context) -> PDFView {
        let v = PDFView()
        v.autoScales = true
        v.displayMode = .singlePageContinuous
        v.document = PDFDocument(url: url)

        // 제스처: 탭 → 메모, 팬 → 필기/지우개
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        v.addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        v.addGestureRecognizer(pan)

        context.coordinator.pdfView = v
        context.coordinator.memoText = memoText
        context.coordinator.getMode = { mode }
        context.coordinator.getURL = { url }
        context.coordinator.onSaved = { saved in lastSavedURL = saved }
        return v
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        context.coordinator.memoText = memoText
    }
    
    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject {
        var memoText: String?
        weak var pdfView: PDFView?
        var getMode: (() -> PDFToolMode)?
        var getURL: (() -> URL)?
        var onSaved: ((URL) -> Void)?
        private var inkPath: UIBezierPath?
        private var inkLayer: CAShapeLayer?

        // MARK: Tap → 메모 추가
        @objc func handleTap(_ g: UITapGestureRecognizer) {
            guard let pdfView, let page = pdfView.page(for: g.location(in: pdfView), nearest: true) else { return }
            let mode = getMode?() ?? .none
            let viewPt = g.location(in: pdfView)
            let pagePt = pdfView.convert(viewPt, to: page)

            switch mode {
            case .stickyNote:
                if let memoText = self.memoText {
                    addSticky(on: page, at: pagePt, contents: memoText)
                    save()
                }
            case .freeText:
                if let memoText = self.memoText {
                    addFreeText(on: page, at: pagePt, text: memoText)
                    save()
                }
            default:
                break
            }
        }

        // MARK: Pan → 잉크/지우개
        @objc func handlePan(_ g: UIPanGestureRecognizer) {
            guard let pdfView else { return }
            let mode = getMode?() ?? .none
            switch mode {
            case .ink(let color, let width):
                switch g.state {
                case .began:
                    beginInkStroke(in: pdfView, at: g.location(in: pdfView), color: color, width: width)
                case .changed:
                    continueInkStroke(in: pdfView, at: g.location(in: pdfView))
                case .ended, .cancelled:
                    commitInkStroke(in: pdfView, color: color, width: width)
                    save()
                default: break
                }

            case .eraser(let radius):
                guard let page = pdfView.page(for: g.location(in: pdfView), nearest: true) else { return }
                let viewPt = g.location(in: pdfView)
                let pagePt = pdfView.convert(viewPt, to: page)
                eraseInk(on: page, around: pagePt, radius: radius)
                if g.state == .ended { save() }

            default:
                break
            }
        }

        // MARK: 메모 구현
        private func addSticky(on page: PDFPage, at pt: CGPoint, contents: String) {
            let rect = CGRect(x: pt.x - 12, y: pt.y - 12, width: 240, height: 240)
            let ann = PDFAnnotation(bounds: rect, forType: .text, withProperties: nil)
            ann.contents = contents
            ann.font = .systemFont(ofSize: 14)
            ann.fontColor = .label
            ann.color = .systemYellow
            ann.setValue("Note", forAnnotationKey: PDFAnnotationKey.iconName)
            page.addAnnotation(ann)
        }

        @objc private func notified(_ notification: Notification) {
           if let page = notification.object as? PDFKitView {
               
               if let annotation = notification.userInfo!["PDFAnnotationHit"] as? PDFAnnotation {
                   print("my custom image")
                   print(annotation.value(forAnnotationKey: .contents))
               }
           }
       }
        
        private func addFreeText(on page: PDFPage, at pt: CGPoint, text: String) {
            let rect = CGRect(x: pt.x, y: pt.y, width: 220, height: 80)
            let ann = PDFAnnotation(bounds: rect, forType: .freeText, withProperties: nil)
            ann.contents = text
            ann.font = .systemFont(ofSize: 14)
            ann.fontColor = .label
            ann.color = .systemYellow
            let border = PDFBorder(); border.lineWidth = 0
            ann.border = border
            page.addAnnotation(ann)
        }

        // MARK: 잉크 구현 (화면에서 미리보기 → PDF Ink로 커밋)
        private func beginInkStroke(in pdfView: PDFView, at viewPt: CGPoint, color: UIColor, width: CGFloat) {
            let path = UIBezierPath()
            path.lineWidth = width
            path.lineCapStyle = .round
            path.move(to: viewPt)
            inkPath = path

            let layer = CAShapeLayer()
            layer.strokeColor = color.cgColor
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = width
            layer.lineCap = .round
            layer.path = path.cgPath
            pdfView.layer.addSublayer(layer)
            inkLayer = layer
        }

        private func continueInkStroke(in pdfView: PDFView, at viewPt: CGPoint) {
            inkPath?.addLine(to: viewPt)
            inkLayer?.path = inkPath?.cgPath
        }

        private func commitInkStroke(in pdfView: PDFView, color: UIColor, width: CGFloat) {
            defer {
                inkLayer?.removeFromSuperlayer()
                inkLayer = nil
                inkPath = nil
            }
            guard let path = inkPath, let page = pdfView.page(for: path.currentPoint, nearest: true) else { return }

            // 화면 좌표 → 페이지 좌표로 변환된 경로 만들기
            let pdfPath = UIBezierPath()
            path.cgPath.applyWithBlock { ptr in
                let el = ptr.pointee
                switch el.type {
                case .moveToPoint:
                    pdfPath.move(to: pdfView.convert(el.points[0], to: page))
                case .addLineToPoint:
                    pdfPath.addLine(to: pdfView.convert(el.points[0], to: page))
                case .addQuadCurveToPoint:
                    pdfPath.addQuadCurve(to: pdfView.convert(el.points[1], to: page),
                                         controlPoint: pdfView.convert(el.points[0], to: page))
                case .addCurveToPoint:
                    pdfPath.addCurve(to: pdfView.convert(el.points[2], to: page),
                                     controlPoint1: pdfView.convert(el.points[0], to: page),
                                     controlPoint2: pdfView.convert(el.points[1], to: page))
                case .closeSubpath:
                    pdfPath.close()
                @unknown default: break
                }
            }

            // Ink Annotation 생성
            let ink = PDFAnnotation(bounds: page.bounds(for: .cropBox), forType: .ink, withProperties: nil)
            let border = PDFBorder(); border.lineWidth = width
            ink.border = border
            ink.color = color
            ink.add(pdfPath)
            page.addAnnotation(ink)
        }

        private func eraseInk(on page: PDFPage, around pt: CGPoint, radius: CGFloat) {
            let area = CGRect(x: pt.x - radius, y: pt.y - radius, width: radius*2, height: radius*2)
            //@ ann.type ann.annotationKey 같은지 확인
            for ann in page.annotations where ann.type == PDFAnnotationSubtype.ink.rawValue {
                if ann.bounds.insetBy(dx: -radius, dy: -radius).intersects(area) {
                    page.removeAnnotation(ann) // 스트로크 단위 삭제(간단 구현)
                }
            }
        }

        private func save() {
            guard let pdfView, let doc = pdfView.document, let url = getURL?() else { return }
            if doc.write(to: url) { onSaved?(url) }
        }
    }
}
