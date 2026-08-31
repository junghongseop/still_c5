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

    @State private var isOptionsPresented = false
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

                    Button {
                        isOptionsPresented = true
                    } label: {
                        optionIndicator
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
            } else {
                Button {
                    isOptionsPresented = true
                } label: {
                    HStack(spacing: 12) {
                        Text(selection?.rawValue ?? placeholder)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(
                                selection == nil
                                    ? StillColors.Content.teriary
                                    : StillColors.Content.primary
                            )

                        Spacer()

                        optionIndicator
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .onChange(of: selection) { _, _ in
            focusCustomFieldIfNeeded()
        }
    }

    @ViewBuilder
    private var optionPopoverContent: some View {
        VStack(spacing: 4) {
            ForEach(Option.options, id: \.self) { option in
                Button {
                    selection = option
                    isOptionsPresented = false
                } label: {
                    HStack(spacing: 12) {
                        Text(option.rawValue)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(StillColors.Content.primary)

                        Spacer()

                        if selection == option {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(StillColors.Accent.primary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 48)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
        .frame(width: 220)
        .presentationCompactAdaptation(.popover)
        .presentationBackground(StillColors.Surface.raised)
    }

    private var optionIndicator: some View {
        Image(systemName: "chevron.up.chevron.down")
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(StillColors.Content.secondary)
            .frame(width: 32, height: 44)
            .popover(
                isPresented: $isOptionsPresented,
                attachmentAnchor: .rect(.bounds),
                arrowEdge: .trailing
            ) {
                optionPopoverContent
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
