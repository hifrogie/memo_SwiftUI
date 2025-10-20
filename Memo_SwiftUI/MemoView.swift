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
    @State private var isViewPdf: Bool = true
    @State private var isMemoPdf: Bool = false
    @State private var isWritePdf: Bool = false
    @State private var isScroll = true
    @State var isShare = false
    @State var isSave = false
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
//                HStack(spacing: 10) {
//                    Toggle("보기", isOn: $isViewPdf)
//                        .background(Color.blue)
//                        .onChange(of: isViewPdf) { oldValue, newValue in
//                            if newValue {
//                                mode = .none
//                                isMemoPdf = false
//                                isWritePdf = false
//                                isScroll = true
//                            }
//                        }
//                    Toggle("메모", isOn: $isMemoPdf)
//                        .background(Color.red)
//                        .onChange(of: isMemoPdf) { oldValue, newValue in
//                            if newValue {
//                                mode = .freeText
//                                isViewPdf = false
//                                isWritePdf = false
//                                isScroll = false
//                            }
//                        }
//                    Toggle("필기", isOn: $isWritePdf)
//                        .background(Color.yellow)
//                        .onChange(of: isWritePdf) {  oldValue, newValue in
//                            if newValue {
//                                mode = .ink(color: .black, width: 3)
//                                isViewPdf = false
//                                isMemoPdf = false
//                                isScroll = false
//                            }
//                        }
//                }.padding(10)
                
                if isMemoPdf {
                    MemoTextField(title: "메모를 입력 후 원하는 위치를 탭 해주세요.", placeholder: "메모를 입력해주세요.", text: $memoText)
                        .padding(.horizontal)
                }
                
                PDFKitView(url: pdfURL, isScroll: isScroll, mode: $mode, lastSavedURL: $savedURL, memoText: memoText)
                
                Button("저장") {
                    if let topVC = UIApplication.shared.connectedScenes
                        .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
                        .first {
                        if let savedURL = savedURL {
                            PDFExporter().exportPDF(savedURL, from: topVC)
                        }
                    }
                }
                Button("공유") { isShare = true }
                    .sheet(isPresented: $isShare) {
                        if let savedURL = savedURL {
                            ShareSheet(items: [savedURL])
                        }
                    }
            }
            .onAppear {
                savedURL = pdfURL
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}

#Preview {
    if let url = URL(string: "www.naver.com") {
        MemoView(pdfURL: url)
    }
}
