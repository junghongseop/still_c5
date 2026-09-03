//
//  MovieSearchMessage.swift
//  Still
//
//  Created by 정홍섭 on 8/31/26.
//

import SwiftUI

struct MovieSearchMessage: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .foregroundStyle(StillColors.Content.secondary)
                .font(.system(size: 36))
            
            VStack(spacing: 6) {
                Text(title)
                    .foregroundStyle(StillColors.Content.primary)
                    .font(.still(.headline))
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .foregroundStyle(StillColors.Content.secondary)
                    .font(.still(.label))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 72)
        .frame(maxWidth: .infinity)
    }
}
