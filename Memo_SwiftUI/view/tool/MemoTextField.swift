//
//  MemoTextField.swift
//  Memo_SwiftUI
//
//  Created by 하고 싶은 걸 하고 살자 on 10/12/25.
//
import SwiftUI

struct MemoTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    @FocusState private var isFocused: Bool  // 포커스 감지용
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 상단 라벨
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .focused($isFocused)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isFocused ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 1.5)
                )
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}


