//
//  TouchOverlay.swift
//  Memo_SwiftUI
//
//  Created by 하고 싶은 걸 하고 살자 on 10/12/25.
//

import UIKit
import PDFKit

final class TouchOverlay: UIView {
    private weak var pdfView: PDFView?
    private var currentPath: UIBezierPath?
    private var shapeLayer: CAShapeLayer?
    private var lastPoint: CGPoint = .zero
    private let toolProvider: () -> InkTool

    init(pdfView: PDFView, tool: @escaping () -> InkTool) {
        self.pdfView = pdfView
        self.toolProvider = tool
        super.init(frame: .zero)
        isMultipleTouchEnabled = false
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError() }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first, let pdfView else { return }
        let p = t.location(in: self)
        lastPoint = p

        switch toolProvider() {
        case .pen(let color, let width):
            let path = UIBezierPath()
            path.lineWidth = width
            path.lineCapStyle = .round
            path.move(to: p)
            currentPath = path

            let layer = CAShapeLayer()
            layer.path = path.cgPath
            layer.lineWidth = width
            layer.strokeColor = color.cgColor
            layer.fillColor = UIColor.clear.cgColor
            layer.lineCap = .round
            self.layer.addSublayer(layer)
            shapeLayer = layer

        case .eraser:
            erase(at: p, in: pdfView)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let p = t.location(in: self)

        switch toolProvider() {
        case .pen(let color, let width):
            currentPath?.addLine(to: p)
            shapeLayer?.path = currentPath?.cgPath
            shapeLayer?.strokeColor = color.cgColor
            shapeLayer?.lineWidth = width

        case .eraser:
            if let pdfView = pdfView { erase(at: p, in: pdfView) }
        }
        lastPoint = p
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pdfView, let doc = pdfView.document else { cleanup(); return }
        defer { cleanup() }

        switch toolProvider() {
        case .pen(let color, let width):
            guard let uiPath = currentPath else { return }
            // 현재 보이는 페이지 계산
            guard let page = pdfView.page(for: lastPoint, nearest: true) else { return }
            // 화면 좌표 → 페이지 좌표로 변환
            // path를 페이지 좌표로 옮겨야 함
            let pdfPath = UIBezierPath()
            let cgPath = uiPath.cgPath
            cgPath.applyWithBlock { elementPtr in
                let element = elementPtr.pointee
                switch element.type {
                case .moveToPoint:
                    let v = element.points[0]
                    let pagePt = pdfView.convert(v, to: page)
                    pdfPath.move(to: pagePt)
                case .addLineToPoint:
                    let v = element.points[0]
                    let pagePt = pdfView.convert(v, to: page)
                    pdfPath.addLine(to: pagePt)
                case .addQuadCurveToPoint:
                    let v1 = element.points[0], v2 = element.points[1]
                    pdfPath.addQuadCurve(to: pdfView.convert(v2, to: page),
                                         controlPoint: pdfView.convert(v1, to: page))
                case .addCurveToPoint:
                    let v1 = element.points[0], v2 = element.points[1], v3 = element.points[2]
                    pdfPath.addCurve(to: pdfView.convert(v3, to: page),
                                     controlPoint1: pdfView.convert(v1, to: page),
                                     controlPoint2: pdfView.convert(v2, to: page))
                case .closeSubpath:
                    pdfPath.close()
                @unknown default:
                    break
                }
            }

            // Ink 주석 만들기
            let bounds = page.bounds(for: .cropBox)
            let ink = PDFAnnotation(bounds: bounds, forType: .ink, withProperties: nil)
            ink.color = color
            let border = PDFBorder()
            border.lineWidth = width
            ink.border = border
            ink.add(pdfPath)
            page.addAnnotation(ink)

            // 문서 변경 알림(저장 필요 시)
            doc.write(to: doc.documentURL ?? tempURL()) // 즉시 덮어쓰기 or 나중에 저장

        case .eraser:
            break
        }
    }

    private func cleanup() {
        shapeLayer?.removeFromSuperlayer()
        shapeLayer = nil
        currentPath = nil
    }

    private func erase(at viewPoint: CGPoint, in pdfView: PDFView) {
        guard let page = pdfView.page(for: viewPoint, nearest: true) else { return }
        let pagePoint = pdfView.convert(viewPoint, to: page)

        // 근처 주석 제거 (Ink만)
        let hitRadius: CGFloat = {
            if case .eraser(let r) = toolProvider() { return r }
            return 10
        }()
        let hitRect = CGRect(x: pagePoint.x - hitRadius,
                             y: pagePoint.y - hitRadius,
                             width: hitRadius * 2,
                             height: hitRadius * 2)

        for ann in page.annotations where ann.type == PDFAnnotationSubtype.ink.rawValue {
            if ann.bounds.insetBy(dx: -hitRadius, dy: -hitRadius).intersects(hitRect) {
                page.removeAnnotation(ann)
            }
        }
    }

    private func tempURL() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("temp.pdf")
    }
}
