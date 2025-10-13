//
//  PDFExporter.swift
//  Memo_SwiftUI
//
//  Created by 하고 싶은 걸 하고 살자 on 10/11/25.
//
import UIKit
import UniformTypeIdentifiers

struct PDFExporter {
    func exportPDF(_ pdfURL: URL, from viewController: UIViewController) {
        let picker = UIDocumentPickerViewController(forExporting: [pdfURL])
        picker.shouldShowFileExtensions = true
        viewController.present(picker, animated: true)
    }
}

