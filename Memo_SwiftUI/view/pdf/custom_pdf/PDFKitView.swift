//
//  PDFKitView.swift
//  Memo_SwiftUI
//
//  Created by 하고 싶은 걸 하고 살자 on 10/11/25.
//
import PDFKit
import SwiftUI

struct PDFKitView: UIViewRepresentable {
    let url: URL
    @Binding var mode: Mode        // 현재 도구 모드
    @Binding var lastSavedURL: URL?
    
    enum Mode { case none, stickyNote, freeText }
    
    func makeUIView(context: Context) -> PDFView {
        let v = PDFView()
        v.autoScales = true
        v.displayMode = .singlePageContinuous
        v.displaysAsBook = false
        v.backgroundColor = .systemBackground
        v.document = PDFDocument(url: url)
        // writing
        let overlay = TouchOverlay(pdfView:  v, tool: { tool })
                overlay.frame =  v.bounds
                overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.addSubview(overlay)
                context.coordinator.overlay = overlay
        // memo
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        v.addGestureRecognizer(tap)
        
        context.coordinator.pdfView = v
        context.coordinator.getMode = { mode }  // 최신 모드 읽기용
        
        return v
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document?.documentURL != url {
            uiView.document = PDFDocument(url: url)
        }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }
    
    final class Coordinator: NSObject {
        var pdfView: PDFView?
        let parent: PDFKitView
        var getMode: (() -> Mode)?
        weak var overlay: TouchOverlay?
        
        init(parent: PDFKitView) { self.parent = parent }
        
        @objc func handleTap(_ g: UITapGestureRecognizer) {
            guard let pdfView, let page = pdfView.page(for: g.location(in: pdfView), nearest: true),
                  let mode = getMode?() else { return }
            
            // 화면 좌표 → 페이지 좌표
            let viewPoint = g.location(in: pdfView)
            let pagePoint = pdfView.convert(viewPoint, to: page)
            
            switch mode {
            case .stickyNote:
                addStickyNote(on: page, at: pagePoint)
            case .freeText:
                addFreeText(on: page, at: pagePoint, text: "여기에 메모 입력")
            case .none:
                break
            }
            
            // 저장(원본에 덮어쓰기) or 복사본 저장
            if let doc = pdfView.document {
                let dest = parent.url // 필요하면 별도 복사 경로로 변경
                if doc.write(to: dest) {
                    parent.lastSavedURL = dest
                }
            }
        }
        
        private func addStickyNote(on page: PDFPage, at pt: CGPoint) {
            // 아이콘이 보이는 영역(크기는 적당히 24x24)
            let rect = CGRect(x: pt.x - 12, y: pt.y - 12, width: 24, height: 24)
            let ann = PDFAnnotation(bounds: rect, forType: .text, withProperties: nil)
            ann.contents = "새 메모"       // 노트를 열면 보이는 본문
            ann.color = .systemYellow      // 아이콘 색
            // 아이콘 모양(옵션): Note, Comment, Key, Help, NewParagraph 등
            ann.setValue("Note", forAnnotationKey: PDFAnnotationKey.iconName)
            page.addAnnotation(ann)
        }
        
        private func addFreeText(on page: PDFPage, at pt: CGPoint, text: String) {
            // 텍스트 박스 영역
            let rect = CGRect(x: pt.x, y: pt.y, width: 200, height: 80)
            let ann = PDFAnnotation(bounds: rect, forType: .freeText, withProperties: nil)
            ann.contents = text
            ann.font = .systemFont(ofSize: 14)
            ann.color = .clear                 // 배경 투명
            ann.fontColor = .label             // 글자색
            ann.alignment = .left
            // 테두리(옵션)
            let border = PDFBorder()
            border.lineWidth = 0.0             // 0=테두리 없음
            ann.border = border
            page.addAnnotation(ann)
        }
    }
}
