//
//  ContentView.swift
//  Memo_SwiftUI
//
//  Created by 하고 싶은 걸 하고 살자 on 10/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showPicker = false
    @State private var showPdfView = false
    @State private var pdfURL:URL?
    
    var body: some View {
        ZStack {
            if showPdfView {
                if let pdfURL = self.pdfURL {
                    MemoView(pdfURL: pdfURL)
                }
            } else {
                VStack(spacing: 16) {
                    Button("PDF 가져오기") { showPicker = true }
                }
                .sheet(isPresented: $showPicker) {
                    PDFDocumentPicker { url in
                        self.pdfURL = url
                        showPdfView = true
                    }
                }
            }
        } .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
