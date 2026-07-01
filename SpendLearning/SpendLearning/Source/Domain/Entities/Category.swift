//
//  Category.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

enum Category: String, CaseIterable {
    case food = "식비"
    case cafe = "카페/간식"
    case transport = "교통"
    case shopping = "쇼핑"
    case medical = "의료"
    case entertainment = "여가"
    case etc = "기타"

    var symbolName: String {
        switch self {
        case .food: return "fork.knife"
        case .cafe: return "cup.and.saucer"
        case .transport: return "bus"
        case .shopping: return "cart"
        case .medical: return "cross.case"
        case .entertainment: return "gamecontroller"
        case .etc: return "ellipsis.circle"
        }
    }

    var displayName: String { rawValue }
}
