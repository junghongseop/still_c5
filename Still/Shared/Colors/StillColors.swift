//
//  StillColors.swift
//  Still
//
//  Created by 정홍섭 on 8/26/26.
//

import SwiftUI

enum StillColors {
    enum Surface {
        static let base: Color = .neutral950
        static let raised: Color = .neutral900
        static let elevated: Color = .neutral800
        static let scrim: Color = .black48
    }
    
    enum Content {
        static let primary: Color = .neutral0
        static let secondary: Color = .neutral300
        static let teriary: Color = .neutral500
        static let onAccent: Color = .neutral0
    }
    
    enum Border {
        static let subtle: Color = .white12
        static let strong: Color = .neutral700
    }
    
    enum Accent {
        static let primary: Color = .red500
        static let strong: Color = .red600
        static let secondary: Color = .magenta500
        static let subtle: Color = .red12
    }
    
    enum Feedback {
        static let success: Color = .green500
        static let warning: Color = .amber500
        static let error: Color = .red400
    }
}
