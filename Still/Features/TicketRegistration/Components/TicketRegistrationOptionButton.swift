//
//  TicketRegistrationOptionButton.swift
//  Still
//

import SwiftUI

struct TicketRegistrationOptionButton: View {
    let title: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(StillColors.Content.primary)

                    Text(description)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(StillColors.Content.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 24))
                    .foregroundStyle(StillColors.Content.secondary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
            .background(StillColors.Surface.raised)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(StillColors.Border.subtle, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    TicketRegistrationOptionButton(
        title: "영화관에서 봤어요",
        description: "티켓 인식 또는 영화 검색으로 등록"
    ) {}
}
