//
//  RegistrationHeader.swift
//  Still
//

import SwiftUI

struct RegistrationHeader: View {
    enum Style {
        case large
        case standard

        var titleSize: CGFloat {
            switch self {
            case .large: 24
            case .standard: 22
            }
        }

        var subtitleSize: CGFloat {
            switch self {
            case .large: 16
            case .standard: 15
            }
        }
    }

    let title: String
    let subtitle: String
    var style: Style = .standard

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: style.titleSize, weight: .regular))
                .foregroundStyle(StillColors.Content.primary)

            Text(subtitle)
                .font(.system(size: style.subtitleSize, weight: .regular))
                .foregroundStyle(StillColors.Content.secondary)
        }
    }
}
