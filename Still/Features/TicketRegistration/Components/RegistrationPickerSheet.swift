//
//  RegistrationPickerSheet.swift
//  Still
//

import SwiftUI

struct RegistrationPickerSheet<Content: View>: View {
    let title: String
    let isConfirmationDisabled: Bool
    let onCancel: () -> Void
    let onConfirm: () -> Void
    @ViewBuilder let content: Content

    init(
        title: String,
        isConfirmationDisabled: Bool = false,
        onCancel: @escaping () -> Void,
        onConfirm: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.isConfirmationDisabled = isConfirmationDisabled
        self.onCancel = onCancel
        self.onConfirm = onConfirm
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.clear)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(title)
                            .font(.still(.headline))
                            .foregroundStyle(StillColors.Content.primary)
                    }

                    ToolbarItem(placement: .cancellationAction) {
                        Button("취소", action: onCancel)
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("완료", action: onConfirm)
                            .disabled(isConfirmationDisabled)
                    }
                }
        }
        .presentationDetents([.height(360)])
        .presentationBackground(StillColors.Surface.base)
        .presentationDragIndicator(.hidden)
    }
}
