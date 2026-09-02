//
//  MovieSearchResults.swift
//  Still
//
//  Created by 정홍섭 on 8/31/26.
//

import SwiftUI

struct MovieSearchResults: View {
    let results: [MovieSearchViewModel.SearchResult]
    let onSelect: (MovieSearchViewModel.SearchResult) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("검색 결과 \(results.count)개")
                .font(.still(.label))
                .foregroundStyle(StillColors.Content.secondary)
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(results.indices, id: \.self) { index in
                        MovieSearchResultRow(
                            result: results[index],
                            action: { onSelect(results[index]) }
                        )
                    }
                }
                .padding(.bottom, 12)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
