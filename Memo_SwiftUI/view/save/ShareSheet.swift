//
//  ShareSheet.swift
//  Memo_SwiftUI
//
//  Created by 하고 싶은 걸 하고 살자 on 10/11/25.
//
import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    var activities: [UIActivity]? = nil
    var completion: UIActivityViewController.CompletionWithItemsHandler? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: items, applicationActivities: activities)
        // iPad 팝오버 안전 포지셔닝
        vc.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.midX,
                                                              y: UIScreen.main.bounds.midY,
                                                              width: 0, height: 0)
        vc.popoverPresentationController?.sourceView = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        vc.completionWithItemsHandler = completion
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

