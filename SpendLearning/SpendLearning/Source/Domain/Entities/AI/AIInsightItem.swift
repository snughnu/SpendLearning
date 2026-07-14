//
//  AIInsightItem.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

enum AIInsightItemType {
    case abnormal, forecast, unrecorded

    var title: String {
        switch self {
        case .abnormal: return "이상 지출 감지"
        case .forecast: return "지출 예고"
        case .unrecorded: return "미기록 감지"
        }
    }
}

struct AIInsightItem {
    let type: AIInsightItemType
    let description: String
}
