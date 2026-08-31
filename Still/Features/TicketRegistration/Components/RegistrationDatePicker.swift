//
//  RegistrationDatePicker.swift
//  Still
//

import SwiftUI

struct RegistrationDatePicker: View {
    let title: String
    @Binding var selection: Date

    @State private var isPickerPresented = false
    @State private var draftSelection = Date()

    var body: some View {
        RegistrationField(title: title) {
            Button {
                draftSelection = selection
                isPickerPresented = true
            } label: {
                HStack(spacing: 12) {
                    Text(
                        selection,
                        format: .dateTime.year().month().day()
                    )
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(StillColors.Content.primary)

                    Spacer()

                    Image(systemName: "calendar")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(StillColors.Content.secondary)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .environment(\.locale, Locale(identifier: "ko_KR"))
        .sheet(isPresented: $isPickerPresented) {
            RegistrationPickerSheet(
                title: title,
                onCancel: { isPickerPresented = false },
                onConfirm: {
                    selection = draftSelection
                    isPickerPresented = false
                }
            ) {
                DatePicker(
                    title,
                    selection: $draftSelection,
                    displayedComponents: .date
                )
                .labelsHidden()
                .datePickerStyle(.wheel)
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .environment(\.colorScheme, .dark)
                .foregroundStyle(StillColors.Content.primary)
                .tint(StillColors.Content.primary)
            }
        }
    }
}
