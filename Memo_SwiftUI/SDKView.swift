//
//  SDKView.swift
//  Memo_SwiftUI
//
//  Created by 이경은 on 10/15/25.
//

import SwiftUI
import PDFKit
import pdf_Viewer_sdk

struct SDKView: View {
    
    //MARK: SDK view 의 단계를 표시하는 값 1/2/3/4 ( 0 없습니다. )
    @State private var step_num: Int = 1
    
    
    //MARK: SDK view 를 띄우는 bool 값
    @State private var isShowPDFView: Bool = false
    
    var body: some View {
        ZStack {
            
            if isShowPDFView {
                VStack(spacing: 0) {
                    HStack {
                        Button(action: {
                            //SDK 화면 닫기 "뒤로가기" 버튼에 대한 액션 리턴
                            isShowPDFView = false
                        }) {
                            //버튼에 대한 ui 설정
                            Label("뒤로가기", systemImage: "chevron.left")
                                .font(.headline)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.gray.opacity(0.8))
                                .cornerRadius(8)
                        }
                        Spacer()
                    }
                    .padding()
                    
                    //SDK view 불러오기
                    PDF_SDK.shared.getVersionView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            
            else {
                VStack(spacing: 20) {
                    Text("PDF Viewer SDK 테스트")
                        .font(.title)
                        .padding(.top, 40)
                    
                    Button("1단계 View 띄우기") {
                        showPDFView(step: .firstStep)
                    }
                    
                    Button("2단계 View 띄우기") {
                        showPDFView(step: .secondStep)
                    }
                    
                    Button("3단계 View 띄우기") {
                        showPDFView(step: .thirdStep)
                    }
                    
                    Button("4단계 View 띄우기") {
                        showPDFView(step: .fourthStep)
                    }
                }
            }
        }
    }
    
    /// SDK 단계 설정 및 표시
    private func showPDFView(step: PDF_STEP_NUM) {
        PDF_SDK.shared.initialize(step_num: step)
        isShowPDFView = true
    }
}

#Preview {
    SDKView()
}

