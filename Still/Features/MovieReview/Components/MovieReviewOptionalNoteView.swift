//
//  MovieReviewOptionalNoteView.swift
//  Still
//

import SwiftUI

struct MovieReviewOptionalNoteView: View {
    private static let characterLimit = 300

    @Binding var note: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("한줄로 남겨볼까요? · 필수")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(StillColors.Content.primary)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text("한줄 감상")
                        .foregroundStyle(StillColors.Content.secondary)

                    Spacer()

                    Text("\(note.count)/\(Self.characterLimit)")
                        .foregroundStyle(StillColors.Content.teriary)
                }
                .font(.system(size: 13, weight: .regular))

                TextField(
                    "",
                    text: $note,
                    prompt: Text(
                        "짧게 남기고 싶은 장면이나 감상을 적어보세요."
                    )
                    .foregroundStyle(StillColors.Content.teriary),
                    axis: .vertical
                )
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(StillColors.Content.primary)
                .textFieldStyle(.plain)
                .lineLimit(3, reservesSpace: true)
                .onChange(of: note) { _, newValue in
                    guard newValue.count > Self.characterLimit else { return }
                    note = String(newValue.prefix(Self.characterLimit))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .frame(height: 124, alignment: .top)
            .background(StillColors.Surface.raised)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(StillColors.Border.subtle, lineWidth: 1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

