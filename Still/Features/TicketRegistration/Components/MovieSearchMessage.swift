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
                    .font(.system(size: 17, weight: .medium))
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .foregroundStyle(StillColors.Content.secondary)
                    .font(.system(size: 15, weight: .regular))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 72)
        .frame(maxWidth: .infinity)
    }
}
