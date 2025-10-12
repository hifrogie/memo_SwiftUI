//
//  MemoView.swift
//  Memo_SwiftUI
//
//  Created by 하고 싶은 걸 하고 살자 on 10/11/25.
//
import Foundation
import SwiftUI

struct MemoView: View {
    @Binding var showPdfView: Bool
    @State var pdfURL: URL
    @StateObject var adapter = PdfViewAdapter()
    @State private var viewPdf: Bool = true
    @State private var memoPdf: Bool = false
    @State private var writePdf: Bool = false
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Toggle("보기", isOn: $viewPdf)
                    .background(Color.blue)
                Toggle("메모", isOn: $memoPdf)
                    .background(Color.red)
                Toggle("필기", isOn: $writePdf)
                    .background(Color.yellow)
            }.padding(.horizontal, 10)
            
            PDFKitView(url: pdfURL)
            
            Button("저장") { adapter.setSaveState(true) }
            Button("공유") { adapter.setShareState(true) }
        }
        .sheet(isPresented: $adapter.isShare) {
            ShareSheet(items: <#T##[Any]#>)
        }
    }
}

#Preview {
    @State var showDetail = true
    if let url = URL(string: "www.naver.com") {
        MemoView(showPdfView: $showDetail, pdfURL: url)
    }
}
