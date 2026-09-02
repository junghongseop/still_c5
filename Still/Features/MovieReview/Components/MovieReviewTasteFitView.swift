//
//  MovieReviewTasteFitView.swift
//  Still
//

import SwiftUI

struct MovieReviewTasteFitView: View {
    @Binding var selection: TasteFitOption

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("내 취향에 얼마나 잘 맞았나요?")
                .font(.still(.headline))
                .foregroundStyle(StillColors.Content.primary)

            HStack(spacing: 6) {
                ForEach(TasteFitOption.allCases) { option in
                    tasteFitButton(for: option)
                }
            }
        }
        .padding(.vertical, 10)
    }

    private func tasteFitButton(for option: TasteFitOption) -> some View {
        let isSelected = selection == option

        return Button {
            selection = option
        } label: {
            Text(option.rawValue)
                .font(.still(.labelEmphasized))
                .foregroundStyle(
                    isSelected
                        ? StillColors.Content.primary
                        : StillColors.Content.secondary
                )
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background {
                    Capsule()
                        .fill(
                            isSelected
                                ? StillColors.Accent.strong
                                : StillColors.Surface.elevated
                        )
                }
                .overlay {
                    Capsule()
                        .stroke(
                            isSelected
                                ? StillColors.Accent.strong
                                : StillColors.Border.subtle,
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
