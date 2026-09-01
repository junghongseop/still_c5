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
    @Query private var tickets: [MovieTicket]
    
    @State private var selectedYear: Int?
    
    private let currentYear = DateUtility.currentYear

    private var filteredTickets: [MovieTicket] {
        guard let selectedYear else { return tickets }

        return tickets.filter {
            Calendar.current.component(.year, from: $0.watchedDate)
                == selectedYear
        }
    }

    private var summaryContent: String {
        let homeCount = filteredTickets.filter {
            $0.place == .home
        }.count
        let theaterCount = filteredTickets.filter {
            $0.place == .theater
        }.count

        guard homeCount + theaterCount > 0 else {
            return "아직 기록된 영화가 없어요"
        }

        if homeCount == theaterCount {
            return "집과 극장에서 같은 수만큼 봤어요"
        }

        return homeCount > theaterCount
            ? "집에서 더 많이 봤어요"
            : "극장에서 더 많이 봤어요"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("홈")
                    .foregroundStyle(StillColors.Content.primary)
                    .bold()
                    .font(.system(size: 44))
                
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
                FilterChip(title: "전체", isSelected: selectedYear == nil) {
                    selectedYear = nil
                }
                
                FilterChip(title: String(currentYear), isSelected: selectedYear == currentYear) {
                    selectedYear = currentYear
                }
            }
            
            MovieSummaryCard(
                filter: selectedYear == currentYear
                    ? String(currentYear)
                    : "전체",
                content: summaryContent
            )
            
            Text("캐릭터")
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 406)
                .background()
        }
        .screenLayoutStyle()
    }
}

#Preview {
    HomeView()
        .environment(AppRouter())
        .modelContainer(for: MovieTicket.self, inMemory: true)
}
