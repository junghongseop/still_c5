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

    nonisolated static func logoSizeRatios(
        for aspectRatio: CGFloat,
        scale: CGFloat = 1
    ) -> CGSize {
        guard aspectRatio > 0 else {
            return CGSize(
                width: logoWidthRatio * scale,
                height: 0.22 * scale
            )
        }

        let maximumWidth = logoWidthRatio * scale
        let maximumHeight = maximumLogoHeightRatio * scale
        let heightAtMaximumWidth = maximumWidth
            * self.aspectRatio
            / aspectRatio

        guard heightAtMaximumWidth > maximumHeight else {
            return CGSize(
                width: maximumWidth,
                height: heightAtMaximumWidth
            )
        }

        return CGSize(
            width: maximumHeight * aspectRatio / self.aspectRatio,
            height: maximumHeight
        )
    }
}

struct MomentTicketLogoPosition: Equatable, Sendable {
    let verticalCenterRatio: CGFloat
    let scale: CGFloat

    nonisolated init(
        verticalCenterRatio: CGFloat,
        scale: CGFloat = 1
    ) {
        self.verticalCenterRatio = verticalCenterRatio
        self.scale = scale
    }

    nonisolated static let bottom = MomentTicketLogoPosition(
        verticalCenterRatio: 0.84,
        scale: 1
    )
}

struct MomentTicket: View {
    private enum ImageSource {
        case asset(String)
        case image(UIImage)
    }

    private let posterSource: ImageSource
    private let logoSource: ImageSource?
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
        logo: UIImage?,
        logoPosition: MomentTicketLogoPosition = .bottom
    ) {
        posterSource = .image(poster)
        logoSource = logo.map(ImageSource.image)
        self.logoPosition = logoPosition
        logoAspectRatio = Self.aspectRatio(of: logo)
    }

    init?(
        posterData: Data,
        logoData: Data?,
        logoVerticalCenterRatio: Double,
        logoScale: Double = 1
    ) {
        guard let poster = UIImage(data: posterData) else { return nil }

        self.init(
            poster: poster,
            logo: logoData.flatMap(UIImage.init(data:)),
            logoPosition: MomentTicketLogoPosition(
                verticalCenterRatio: CGFloat(logoVerticalCenterRatio),
                scale: CGFloat(logoScale)
            )
        )
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
            let logoSize = MomentTicketLayout.logoSizeRatios(
                for: logoAspectRatio,
                scale: logoPosition.scale
            )

            image(for: posterSource)
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .overlay {
                    if let logoSource {
                        image(for: logoSource)
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: geo.size.width * logoSize.width,
                                height: geo.size.height * logoSize.height
                            )
                            .position(
                                x: geo.size.width / 2,
                                y: geo.size.height
                                    * logoPosition.verticalCenterRatio
                            )
                    }
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
