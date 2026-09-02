//
//  StillTypography.swift
//  Still
//

import SwiftUI

/// Still의 텍스트 스타일과 Pretendard 굵기를 한곳에서 관리합니다.
enum StillTypography {
    fileprivate enum Weight: String {
        case regular = "Pretendard-Regular"
        case medium = "Pretendard-Medium"
        case semibold = "Pretendard-SemiBold"
        case bold = "Pretendard-Bold"
    }

    enum Style {
        /// 화면의 최상위 제목
        case display
        /// 완료 화면처럼 강한 주목이 필요한 제목
        case heroTitle
        /// 화면 내부의 주요 섹션 제목
        case sectionTitle
        /// 카드와 다이얼로그의 작은 제목
        case title
        /// 버튼과 질문 제목
        case headline
        /// 기본 본문
        case body
        /// 강조된 기본 본문
        case bodyEmphasized
        /// 설명, 필드 라벨, 메타데이터
        case label
        /// 강조된 라벨
        case labelEmphasized
        /// 가장 작은 안내 문구
        case caption
        /// 강조된 캡션
        case captionEmphasized

        fileprivate var size: CGFloat {
            switch self {
            case .display: 40
            case .heroTitle: 28
            case .sectionTitle: 22
            case .title: 20
            case .headline: 17
            case .body, .bodyEmphasized: 16
            case .label, .labelEmphasized: 14
            case .caption, .captionEmphasized: 12
            }
        }

        fileprivate var defaultWeight: Weight {
            switch self {
            case .display:
                .bold
            case .heroTitle, .sectionTitle, .headline:
                .semibold
            case .title, .bodyEmphasized, .labelEmphasized,
                    .captionEmphasized:
                .medium
            default:
                .regular
            }
        }

        fileprivate var relativeTo: Font.TextStyle {
            switch self {
            case .display: .largeTitle
            case .heroTitle: .title
            case .sectionTitle: .title2
            case .title: .title3
            case .headline: .headline
            case .body, .bodyEmphasized: .body
            case .label, .labelEmphasized: .subheadline
            case .caption, .captionEmphasized: .caption2
            }
        }
    }

    static func font(_ style: Style) -> Font {
        Font.custom(
            style.defaultWeight.rawValue,
            size: style.size,
            relativeTo: style.relativeTo
        )
    }
}

extension Font {
    static func still(_ style: StillTypography.Style) -> Font {
        StillTypography.font(style)
    }
}
