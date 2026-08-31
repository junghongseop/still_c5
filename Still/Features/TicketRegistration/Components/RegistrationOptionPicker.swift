//
//  RegistrationOptionPicker.swift
//  Still
//

import SwiftUI

struct RegistrationOptionPicker<Option: Hashable>: View {
    let title: String
    let placeholder: String
    @Binding var selection: Option?
    @Binding var customText: String
    let customPlaceholder: String
    let options: [Option]
    let optionTitle: (Option) -> String
    let isCustomOption: (Option) -> Bool

    @FocusState private var isCustomTextFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(StillColors.Content.secondary)

            if isCustomSelection {
                ZStack(alignment: .trailing) {
                    TextField(
                        "",
                        text: $customText,
                        prompt: Text(customPlaceholder)
                            .foregroundStyle(StillColors.Content.teriary)
                    )
                    .focused($isCustomTextFocused)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(StillColors.Content.primary)
                    .padding(.trailing, 44)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Menu {
                        optionMenuContent
                    } label: {
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(StillColors.Content.secondary)
                            .frame(width: 32, height: 44)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 64)
                .background(StillColors.Surface.raised)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(StillColors.Border.subtle, lineWidth: 1)
                }
            } else {
                HStack(spacing: 12) {
                    Text(selection.map(optionTitle) ?? placeholder)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(
                            selection == nil
                                ? StillColors.Content.teriary
                                : StillColors.Content.primary
                        )

                    Spacer()

                    Menu {
                        optionMenuContent
                    } label: {
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(StillColors.Content.secondary)
                            .frame(width: 32, height: 44)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 64)
                .background(StillColors.Surface.raised)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(StillColors.Border.subtle, lineWidth: 1)
                }
            }
        }
        .onChange(of: selection) { _, _ in
            focusCustomFieldIfNeeded()
        }
    }

    @ViewBuilder
    private var optionMenuContent: some View {
        ForEach(options, id: \.self) { option in
            Button {
                selection = option
            } label: {
                if selection == option {
                    Label(optionTitle(option), systemImage: "checkmark")
                } else {
                    Text(optionTitle(option))
                }
            }
        }
    }

    private var isCustomSelection: Bool {
        selection.map(isCustomOption) ?? false
    }

    private func focusCustomFieldIfNeeded() {
        guard isCustomSelection else { return }
        isCustomTextFocused = true
    }
}
