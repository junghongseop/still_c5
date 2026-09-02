//
//  CollectionDetailLayout.swift
//  Still
//

import CoreGraphics

nonisolated struct CollectionDetailLayout {
    let ticketWidth: CGFloat
    let ticketContentSpacing: CGFloat

    init(size: CGSize) {
        let heightProgress = min(
            max((size.height - 600) / 250, 0),
            1
        )
        let widthBasedTicketWidth = min(
            max(size.width * 0.49, 176),
            210
        )
        let heightBasedTicketWidth = 176 + (34 * heightProgress)

        ticketWidth = min(
            widthBasedTicketWidth,
            heightBasedTicketWidth,
            max(size.width - 48, 0)
        )
        ticketContentSpacing = 48 + (47 * heightProgress)
    }
}
