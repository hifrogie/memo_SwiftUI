//
//  PDFDocumentManager.swift
//  Memo_SwiftUI
//
//  Created by 하고 싶은 걸 하고 살자 on 10/11/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct PDFDocumentPicker: UIViewControllerRepresentable {
    var onPick: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        //asCopy : 앱 샌드박스에 카피된다.
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf], asCopy: true)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        init(onPick: @escaping (URL) -> Void) { self.onPick = onPick }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }

            // 파일 제공자(파일 앱/iCloud 등)에서 온 보안 범위 URL 접근
            let needsSecurity = url.startAccessingSecurityScopedResource()
            defer { if needsSecurity { url.stopAccessingSecurityScopedResource() } }

            // 앱 샌드박스로 복사(권장)
            do {
                let dest = try Self.copyToDocuments(url: url)
                onPick(dest)
            } catch {
                print("Copy failed: \(error)")
            }
        }

        private static func copyToDocuments(url: URL) throws -> URL {
            let fm = FileManager.default
            let docs = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let dest = docs.appendingPathComponent(url.lastPathComponent)
            if fm.fileExists(atPath: dest.path) { try fm.removeItem(at: dest) }
            try fm.copyItem(at: url, to: dest)
            return dest
        }
    }
}
