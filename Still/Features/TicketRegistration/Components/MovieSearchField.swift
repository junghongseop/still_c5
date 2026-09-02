//
//  MovieSearchField.swift
//  Still
//
//  Created by 정홍섭 on 8/31/26.
//

import SwiftUI

struct MovieSearchField: View {
    @Binding var text: String
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(StillColors.Content.secondary)
            
            TextField(
                "",
                text: $text,
                prompt: Text("영화 제목을 입력해 주세요")
                    .foregroundStyle(StillColors.Content.secondary)
            )
            .font(.still(.bodyEmphasized))
            .foregroundStyle(StillColors.Content.primary)
            .focused($isFocused)
            .submitLabel(.search)
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(StillColors.Content.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(StillColors.Surface.raised)
        .cornerRadius(16)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isFocused
                    ? StillColors.Accent.primary
                    : StillColors.Border.subtle,
                    lineWidth: 1.5
                )
        }
        .onTapGesture {
            isFocused = true
        }
    }
}

#Preview {
    @Previewable @State var text = "스파이더맨"
    
    ZStack {
        StillColors.Surface.base
            .ignoresSafeArea()
        
        MovieSearchField(text: $text)
            .padding(.horizontal, 20)
    }
}
