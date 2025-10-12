//
//  InkTool.swift
//  Memo_SwiftUI
//
//  Created by 하고 싶은 걸 하고 살자 on 10/12/25.
//
import SwiftUI
import PDFKit

enum InkTool: Equatable {
    case pen(color: UIColor, width: CGFloat)
    case eraser(radius: CGFloat)

    static var defaultPen: InkTool { .pen(color: .systemBlue, width: 3) }
}

