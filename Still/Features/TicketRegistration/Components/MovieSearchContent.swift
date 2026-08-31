//
//  MovieSearchContent.swift
//  Still
//
//  Created by 정홍섭 on 8/31/26.
//

import SwiftUI

struct MovieSearchContent: View {
    let title: String
    let subTitle: String
    let onSelect: (MovieSearchViewModel.SearchResult) -> Void
    
    @State private var searchText = ""
    @State private var viewModel = MovieSearchViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(StillColors.Content.primary)
                
                Text(subTitle)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(StillColors.Content.secondary)
            }
            
            MovieSearchField(text: $searchText)
                .onSubmit {
                    Task {
                        _ = await viewModel.searchMovie(title: searchText)
                    }
                }
                .onChange(of: searchText) {
                    viewModel.clearSearchResults()
                }
            
            if viewModel.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .controlSize(.large)
                        .tint(StillColors.Accent.primary)
                    
                    Text("영화 정보를 불러오는 중")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(StillColors.Content.secondary)
                }
                .padding(.top, 72)
                .frame(maxWidth: .infinity)
            } else if viewModel.didCompleteSearch && viewModel.searchResults.isEmpty {
                MovieSearchMessage(
                    icon: "exclamationmark.triangle.fill",
                    title: "검색 결과가 없어요",
                    description: "\"\(viewModel.searchedQuery)\" 검색 결과를 찾지 못했어요\n띄어쓰기나 제목을 다시 확인해 주세요"
                )
            } else if viewModel.searchResults.isEmpty {
                MovieSearchMessage(
                    icon: "magnifyingglass",
                    title: "영화를 검색해 보세요",
                    description: "제목을 입력한 뒤 키보드의 검색 버튼을 누르세요."
                )
            } else {
                MovieSearchResults(
                    results: viewModel.searchResults,
                    onSelect: onSelect
                )
            }
        }
    }
}

#Preview {
    MovieSearchContent(
        title: "영화관",
        subTitle: "ㅎㅎ",
        onSelect: { _ in }
    )
        .background(StillColors.Surface.base)
}
