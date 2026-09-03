//
//  ScreenLayoutStyle.swift
//  Still
//
//  Created by 정홍섭 on 8/27/26.
//

import SwiftUI

struct ScreenLayoutStyle: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            StillColors.Surface.base
                .ignoresSafeArea()

            content
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
        }
    }
}

extension View {
    func screenLayoutStyle() -> some View {
        modifier(ScreenLayoutStyle())
    }
}
