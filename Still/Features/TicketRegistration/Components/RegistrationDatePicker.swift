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
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(StillColors.Content.secondary)

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
            .buttonStyle(.plain)
        }
        .environment(\.locale, Locale(identifier: "ko_KR"))
        .sheet(isPresented: $isPickerPresented) {
            NavigationStack {
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.clear)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(StillColors.Content.primary)
                    }

                    ToolbarItem(placement: .cancellationAction) {
                        Button("취소") {
                            isPickerPresented = false
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("완료") {
                            selection = draftSelection
                            isPickerPresented = false
                        }
                    }
                }
            }
            .presentationDetents([.height(360)])
            .presentationBackground(StillColors.Surface.base)
            .presentationDragIndicator(.hidden)
        }
    }
}
