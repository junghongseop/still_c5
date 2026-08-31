//
//  MovieReviewView.swift
//  Still
//
//  Created by 정홍섭 on 8/31/26.
//

import SwiftUI

struct MovieReviewView: View {
    let movieID: Int

    var body: some View {
        Text("\(movieID)")
    }
}

#Preview {
    MovieReviewView(movieID: 12345)
}
