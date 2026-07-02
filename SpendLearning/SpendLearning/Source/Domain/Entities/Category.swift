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
    case medical = "의료/건강"
    case entertainment = "여가"
    case communication = "통신비"
    case celebration = "경조사"
    case subscription = "구독"
    case etc = "기타"

    var emoji: String {
        switch self {
        case .food: return "🍚"
        case .cafe: return "☕️"
        case .transport: return "🚌"
        case .shopping: return "🛍️"
        case .medical: return "💊"
        case .entertainment: return "🎮"
        case .communication: return "📞"
        case .celebration: return "✉️"
        case .subscription: return "🧾"
        case .etc: return "📦"
        }
    }

    var displayName: String { rawValue }
}
