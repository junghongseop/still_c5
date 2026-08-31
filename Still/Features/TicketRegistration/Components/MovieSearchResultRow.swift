//
//  MovieSearchResultRow.swift
//  Still
//
//  Created by 정홍섭 on 8/31/26.
//

import SwiftUI

struct MovieSearchResultRow: View {
    let result: MovieSearchViewModel.SearchResult
    
    private var metadata: String {
        [DateUtility.year(from: result.releaseDate), result.originalTitle]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(result.title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(StillColors.Content.primary)
                    .lineLimit(1)
                
                Text(metadata)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(StillColors.Content.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 24, weight: .regular))
                .foregroundStyle(StillColors.Content.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(StillColors.Surface.raised)
        .cornerRadius(16)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(StillColors.Border.subtle, lineWidth: 1)
        }
    }
}
