//
//  HomeView.swift
//  Still
//
//  Created by 정홍섭 on 8/18/26.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HomeViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("홈")
                    .foregroundStyle(StillColors.Content.primary)
                    .font(.still(.display))
                
                Spacer()
                
                Button {
                    router.push(.setting)
                } label: {
                    Image(systemName: "person")
                        .font(.system(size: 22))
                        .foregroundStyle(StillColors.Content.primary)
                }
            }

            HStack(spacing: 8) {
                FilterChip(
                    title: "전체",
                    isSelected: viewModel.selectedYear == nil
                ) {
                    viewModel.selectedYear = nil
                }
                
                FilterChip(
                    title: String(viewModel.currentYear),
                    isSelected: viewModel.selectedYear
                        == viewModel.currentYear
                ) {
                    viewModel.selectedYear = viewModel.currentYear
                }
            }

            MovieSummaryCard(
                filter: viewModel.summaryFilter,
                content: viewModel.summaryContent
            )

            Spacer()

            Image("timiBase")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 406)
                .accessibilityLabel("영화 티켓 캐릭터 티미")

            Spacer()
        }
        .screenLayoutStyle()
        .onAppear {
            viewModel.load(modelContext: modelContext)
        }
    }
}

#Preview {
    HomeView()
        .environment(AppRouter())
        .modelContainer(for: MovieTicket.self, inMemory: true)
}
