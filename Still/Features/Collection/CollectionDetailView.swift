//
//  CollectionDetailView.swift
//  Still
//
//  Created by 정홍섭 on 8/28/26.
//

import SwiftUI

struct CollectionDetailView: View {
    var body: some View {
        ZStack {
            Image("spiderman")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .blur(radius: 5)
                .overlay {
                    StillColors.Surface.scrim
                }
                .ignoresSafeArea()
                .scaledToFill()
        }
        .toolbarVisibility(.hidden, for: .tabBar)
    }
}

#Preview {
    CollectionDetailView()
}
