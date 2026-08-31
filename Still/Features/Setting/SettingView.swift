//
//  SettingView.swift
//  Still
//
//  Created by 정홍섭 on 8/19/26.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("설정")
                .foregroundStyle(StillColors.Content.primary)
                .bold()
                .font(.system(size: 44))
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .screenLayoutStyle()
    }
}

#Preview {
    SettingView()
}
