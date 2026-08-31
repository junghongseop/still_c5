//
//  RegistrationOptionPicker.swift
//  Still
//

import SwiftUI

struct RegistrationOptionPicker<Option: RegistrationOption>: View {
    let title: String
    let placeholder: String
    @Binding var selection: Option?
    @Binding var customText: String
    let customPlaceholder: String

    @FocusState private var isCustomTextFocused: Bool

    var body: some View {
        RegistrationField(title: title) {
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
                .frame(maxWidth: .infinity)
            } else {
                HStack(spacing: 12) {
                    Text(selection?.rawValue ?? placeholder)
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
                .frame(maxWidth: .infinity)
            }
        }
        .onChange(of: selection) { _, _ in
            focusCustomFieldIfNeeded()
        }
    }

    @ViewBuilder
    private var optionMenuContent: some View {
        ForEach(Option.options, id: \.self) { option in
            Button {
                selection = option
            } label: {
                if selection == option {
                    Label(option.rawValue, systemImage: "checkmark")
                } else {
                    Text(option.rawValue)
                }
            }
        }
    }

    private var isCustomSelection: Bool {
        selection == Option.customOption
    }

    private func focusCustomFieldIfNeeded() {
        guard isCustomSelection else { return }
        isCustomTextFocused = true
    }
}
