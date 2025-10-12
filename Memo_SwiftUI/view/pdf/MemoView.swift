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
    @State var memoText = ""
    @State var pdfURL: URL
    @State private var mode: PDFToolMode = .none
    @State private var savedURL: URL?
    @StateObject var adapter = PdfViewAdapter()
    @State private var isViewPdf: Bool = true
    @State private var isMemoPdf: Bool = false
    @State private var isWritePdf: Bool = false
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Toggle("보기", isOn: $isViewPdf)
                    .background(Color.blue)
                    .onChange(of: isViewPdf) { value in
                        mode = .none
                    }
                Toggle("메모", isOn: $isMemoPdf)
                    .background(Color.red)
                    .onChange(of: isMemoPdf) { value in
                        mode = .stickyNote
                    }
                Toggle("필기", isOn: $isWritePdf)
                    .background(Color.yellow)
                    .onChange(of: isWritePdf) { value in
                        mode = .ink(color: .black, width: 3)
                    }
            }.padding(.horizontal, 10)
            
            PDFKitView(url: pdfURL, mode: $mode, lastSavedURL: $savedURL, memoText: $memoText)
                .frame(width: 360, height: 600)
            Button("저장") { adapter.setSaveState(true) }
            Button("공유") { adapter.setShareState(true) }
        }
        .safeAreaInset(edge: .top) {
            if isMemoPdf {
                MemoTextField(title: "메모를 입력 후 원하는 위치를 탭 해주세요.", placeholder: "메모를 입력해주세요.", text: $memoText)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
            }
        }
        .sheet(isPresented: $adapter.isShare) {
            if let savedURL = savedURL {
                ShareSheet(items: [savedURL])
            }
        }
    }
}

#Preview {
    @State var showDetail = true
    if let url = URL(string: "www.naver.com") {
        MemoView(showPdfView: $showDetail, pdfURL: url)
    }
}
