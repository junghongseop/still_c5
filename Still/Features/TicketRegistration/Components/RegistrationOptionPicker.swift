//
//  RegistrationOptionPicker.swift
//  Still
//

import SwiftUI

struct RegistrationOptionPicker<Option: RegistrationOption>: View {
    let title: String
    let placeholder: String
    @Binding var selection: Option?

    var body: some View {
        RegistrationField(title: title) {
            Menu {
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

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(StillColors.Content.secondary)
                        .frame(width: 32, height: 44)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .environment(\.colorScheme, .dark)
        }
    }
}
