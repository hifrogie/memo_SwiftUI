//
//  PDFExporter.swift
//  Memo_SwiftUI
//
//  Created by 하고 싶은 걸 하고 살자 on 10/11/25.
//
import SwiftUI
import UIKit

enum PDFExportError: Error { case writeFailed }

struct PDFExporter {
    /// SwiftUI View를 A4(72dpi) 한 페이지 PDF로 렌더링하여 파일로 저장하고 URL 반환
    static func exportA4(
        fileName: String,
        pdfView: PDFKitView
    ) throws -> URL {
        // A4 @72dpi 크기 (포인트): 595 x 842
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        // SwiftUI View -> UIKit View로 호스팅
        let host = UIHostingController(rootView: pdfView)
        host.view.frame = pageRect
        host.view.backgroundColor = .white

        // PDF 데이터 만들기
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            // 최신 렌더링은 메인스레드에서
            host.view.drawHierarchy(in: pageRect, afterScreenUpdates: true)
        }

        // 저장 경로 (Documents)
        let docs = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let url = docs.appendingPathComponent("\(fileName).pdf")

        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            throw PDFExportError.writeFailed
        }
    }
}

