//
//  TicketDeleteAlert.swift
//  Still
//

import SwiftUI
import UIKit

struct TicketDeleteAlert: View {
    let onCancel: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.24)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("이 티켓을 삭제할까요?")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(uiColor: .label))

                Text("삭제한 티켓은 복구할 수 없어요.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .padding(.top, 6)

                HStack(spacing: 12) {
                    alertButton(
                        title: "취소",
                        foreground: StillColors.Accent.primary,
                        background: Color(uiColor: .tertiarySystemFill),
                        action: onCancel
                    )

                    alertButton(
                        title: "삭제",
                        foreground: StillColors.Content.primary,
                        background: StillColors.Accent.primary,
                        action: onDelete
                    )
                }
                .padding(.top, 24)
            }
            .padding(24)
            .frame(maxWidth: 360)
            .glassEffect(
                .regular,
                in: .rect(cornerRadius: 32)
            )
            .padding(.horizontal, 24)
        }
        .accessibilityAddTraits(.isModal)
    }

    private func alertButton(
        title: String,
        foreground: Color,
        background: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(foreground)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(background, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
