//
//  MomentTicket.swift
//  Still
//
//  Created by 정홍섭 on 8/20/26.
//

import SwiftUI
import UIKit

enum MomentTicketLayout {
    nonisolated static let aspectRatio: CGFloat = 140 / 278
    nonisolated static let logoWidthRatio: CGFloat = 0.88
    nonisolated static let maximumLogoHeightRatio: CGFloat = 0.6

    nonisolated static func logoHeightRatio(
        for aspectRatio: CGFloat
    ) -> CGFloat {
        guard aspectRatio > 0 else { return 0.22 }

        return min(
            logoWidthRatio * self.aspectRatio / aspectRatio,
            maximumLogoHeightRatio
        )
    }
}

struct MomentTicketLogoPosition: Equatable, Sendable {
    let verticalCenterRatio: CGFloat

    nonisolated static let bottom = MomentTicketLogoPosition(
        verticalCenterRatio: 0.84
    )
}

struct MomentTicket: View {
    private enum ImageSource {
        case asset(String)
        case image(UIImage)
    }

    private let posterSource: ImageSource
    private let logoSource: ImageSource
    private let logoPosition: MomentTicketLogoPosition
    private let logoAspectRatio: CGFloat

    init(
        poster: String,
        logo: String,
        logoPosition: MomentTicketLogoPosition = .bottom
    ) {
        posterSource = .asset(poster)
        logoSource = .asset(logo)
        self.logoPosition = logoPosition
        logoAspectRatio = Self.aspectRatio(of: UIImage(named: logo))
    }

    init(
        poster: UIImage,
        logo: UIImage,
        logoPosition: MomentTicketLogoPosition = .bottom
    ) {
        posterSource = .image(poster)
        logoSource = .image(logo)
        self.logoPosition = logoPosition
        logoAspectRatio = Self.aspectRatio(of: logo)
    }

    private static func aspectRatio(of image: UIImage?) -> CGFloat {
        guard let image, image.size.height > 0 else { return 2 }
        return image.size.width / image.size.height
    }

    private func image(for source: ImageSource) -> Image {
        switch source {
        case .asset(let name):
            Image(name)

        case .image(let image):
            Image(uiImage: image)
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            image(for: posterSource)
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .overlay {
                    image(for: logoSource)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: geo.size.width
                                * MomentTicketLayout.logoWidthRatio,
                            height: geo.size.height
                                * MomentTicketLayout.logoHeightRatio(
                                    for: logoAspectRatio
                                )
                        )
                        .position(
                            x: geo.size.width / 2,
                            y: geo.size.height
                                * logoPosition.verticalCenterRatio
                        )
                }
                .mask {
                    Image("ticketMask")
                        .resizable()
                        .scaledToFit()
                }
                .clipped()
        }
        .aspectRatio(MomentTicketLayout.aspectRatio, contentMode: .fit)
    }
}

#Preview {
    MomentTicket(poster: "spiderman", logo: "logo")
}
