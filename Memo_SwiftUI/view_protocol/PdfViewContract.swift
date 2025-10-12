//
//  PdfViewContract.swift
//  Memo_SwiftUI
//
//  Created by 하고 싶은 걸 하고 살자 on 10/11/25.
//
import Foundation

protocol PdfViewContract: AnyObject {
    func setShareState(_ isShare: Bool)
    func setSaveState(_ isSave: Bool)
}
