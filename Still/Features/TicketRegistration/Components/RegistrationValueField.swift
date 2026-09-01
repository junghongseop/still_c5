//
//  RegistrationValueField.swift
//  Still
//

import SwiftUI

struct RegistrationValueField: View {
    let title: String
    let value: String

    var body: some View {
        RegistrationField(title: title) {
            Text(value)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(StillColors.Content.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
        }
    }
}
