//
//  MomentTicket.swift
//  Still
//
//  Created by 정홍섭 on 8/20/26.
//

import SwiftUI

struct MomentTicket: View {
    var body: some View {
        GeometryReader { geo in
            Image("spiderman")
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .overlay {
                    VStack {
                        Spacer()
                        
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width)
                            .padding(.vertical, geo.size.height * 0.05)
                    }
                }
                .mask {
                    Image("ticketMask")
                        .resizable()
                        .scaledToFit()
                }
                .clipped()
        }
        .aspectRatio(140 / 278, contentMode: .fit)
    }
}

#Preview {
    MomentTicket()
}
