//
//  RegistrationHeader.swift
//  Still
//

import SwiftUI

struct RegistrationHeader: View {
    enum Style {
        case large
        case standard

        var titleTextStyle: StillTypography.Style {
            switch self {
            case .large: .sectionTitle
            case .standard: .title
            }
        }

        var subtitleTextStyle: StillTypography.Style {
            switch self {
            case .large: .body
            case .standard: .label
            }
        }
    }

    let title: String
    let subtitle: String
    var style: Style = .standard

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.still(style.titleTextStyle))
                .foregroundStyle(StillColors.Content.primary)

            Text(subtitle)
                .font(.still(style.subtitleTextStyle))
                .foregroundStyle(StillColors.Content.secondary)
        }
    }
}
