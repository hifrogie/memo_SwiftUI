//
//  MemoView.swift
//  Memo_SwiftUI
//
//  Created by 하고 싶은 걸 하고 살자 on 10/11/25.
//
import Foundation
import SwiftUI

struct MemoView: View {
    @State var memoText = ""
    @State var pdfURL: URL
    @State private var mode: PDFToolMode = .none
    @State private var savedURL: URL?
    @StateObject var adapter = PdfViewAdapter()
    @State private var isViewPdf: Bool = true
    @State private var isMemoPdf: Bool = false
    @State private var isWritePdf: Bool = false
    @State private var isScroll = true
    var body: some View {
        VStack {
            if isMemoPdf {
                MemoTextField(title: "메모를 입력 후 원하는 위치를 탭 해주세요.", placeholder: "메모를 입력해주세요.", text: $memoText)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
            }
            HStack(spacing: 10) {
                Toggle("보기", isOn: $isViewPdf)
                    .background(Color.blue)
                    .onChange(of: isViewPdf) { value in
                        if value {
                            mode = .none
                            isMemoPdf = false
                            isWritePdf = false
                            isScroll = true
                        }
                    }
                Toggle("메모", isOn: $isMemoPdf)
                    .background(Color.red)
                    .onChange(of: isMemoPdf) { value in
                        if value {
                            mode = .freeText
                            isViewPdf = false
                            isWritePdf = false
                            isScroll = false
                        }
                    }
                Toggle("필기", isOn: $isWritePdf)
                    .background(Color.yellow)
                    .onChange(of: isWritePdf) { value in
                        if value {
                            mode = .ink(color: .black, width: 3)
                            isViewPdf = false
                            isMemoPdf = false
                            isScroll = false
                        }
                    }
            }.padding(.horizontal, 10)
            
            PDFKitView(url: pdfURL, isScroll: isScroll, mode: $mode, lastSavedURL: $savedURL, memoText: memoText)
                .frame(width: 360, height: 600)
            
            Button("저장") { adapter.setSaveState(true) }
            Button("공유") { adapter.setShareState(true) }
        }
        .sheet(isPresented: $adapter.isShare) {
            if let savedURL = savedURL {
                ShareSheet(items: [savedURL])
            }
        }
    }
}

#Preview {
    if let url = URL(string: "www.naver.com") {
        MemoView(pdfURL: url)
    }
}
