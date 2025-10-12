//
//  PdfViewAdapter.swift
//  Memo_SwiftUI
//
//  Created by 하고 싶은 걸 하고 살자 on 10/11/25.
//
import Foundation

final class PdfViewAdapter: ObservableObject, PdfViewContract {
    @Published var isShare = false
    @Published var isSave = false
    
    func setShareState(_ isShare: Bool) {
        self.isShare = isShare
    }
    
    func setSaveState(_ isSave: Bool) {
        self.isSave = isSave
    }
}
