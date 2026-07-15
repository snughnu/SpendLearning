//
//  AIStrategySelector.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/15/26.
//

import Foundation

enum AIStrategySelector {

    /// 이번 달을 제외하고, 지출이 1건 이상 있는 서로 다른 달(YYYY-MM)이 4개 이상이면 true
    static func hasEnoughDataForCoreML(expenses: [Expense], calendar: Calendar = .current, now: Date = Date()) -> Bool {
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)

        let months = Set(expenses.compactMap { expense -> String? in
            let y = calendar.component(.year, from: expense.date)
            let m = calendar.component(.month, from: expense.date)
            guard !(y == currentYear && m == currentMonth) else { return nil }
            return "\(y)-\(m)"
        })

        return months.count >= 4
    }
}
