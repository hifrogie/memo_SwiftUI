//
//  PDFToolMode.swift
//  Memo_SwiftUI
//
//  Created by 하고 싶은 걸 하고 살자 on 10/12/25.
//
import Foundation
import UIKit

enum PDFToolMode: Equatable {
    case none
    case stickyNote                   // 포스트잇(아이콘 + 팝오버)  → .text
    case freeText                     // 페이지 위 텍스트박스      → .freeText
    case ink(color: UIColor, width: CGFloat) // 자유필기            → .ink
    case eraser(radius: CGFloat)      // 스트로크 단위 지우개
}

