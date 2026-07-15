//
//  StatisticsPredictor.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

import Foundation

final class StatisticsPredictor {

    // MARK: - predictDaily

    /// 이번 달 일별 예측 지출 금액을 반환한다.
    /// 폴백 순서:
    /// 1. 과거 같은 주차 + 같은 요일 지출 평균
    /// 2. 데이터 없으면 → 과거 같은 주차 전체 지출 평균
    /// 3. 데이터 없으면 → 과거 월 평균 총액 / 이번 달 일수
    func predictDaily(expenses: [Expense], year: Int, month: Int) async -> [Int: Int] {
        let calendar = Calendar.current
        guard let targetDate = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let dayRange = calendar.range(of: .day, in: .month, for: targetDate) else {
            return [:]
        }

        // 예측 대상 달(이번 달)은 아직 진행 중이므로 평균 계산에서 제외
        let pastExpenses = expenses.filter {
            let y = calendar.component(.year, from: $0.date)
            let m = calendar.component(.month, from: $0.date)
            return !(y == year && m == month)
        }

        let monthlyTotal = monthlyAverage(expenses: pastExpenses)

        var result: [Int: Int] = [:]
        for day in dayRange {
            guard let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) else { continue }
            let weekOfMonth = calendar.component(.weekOfMonth, from: date)
            let weekday = calendar.component(.weekday, from: date)

            if let avg = weekOfMonthAndWeekdayAverage(expenses: pastExpenses, weekOfMonth: weekOfMonth, weekday: weekday), avg > 0 {
                // 1순위: 같은 주차 + 같은 요일 평균
                result[day] = avg
            } else if let avg = weekOfMonthAverage(expenses: pastExpenses, weekOfMonth: weekOfMonth), avg > 0 {
                // 2순위: 같은 주차 전체 평균
                result[day] = avg
            } else {
                // 3순위: 월 평균 총액 / 일수
                result[day] = monthlyTotal / dayRange.count
            }
        }
        return result
    }

    // MARK: - predictCategory

    /// 이번 달 카테고리별 예측 지출 금액을 반환한다.
    /// 과거 카테고리별 월 평균을 계산해 반환한다.
    func predictCategory(expenses: [Expense], year: Int, month: Int) async -> [String: Int] {
        let calendar = Calendar.current

        // 예측 대상 달(이번 달)은 아직 진행 중이므로 평균 계산에서 제외
        let pastExpenses = expenses.filter {
            let y = calendar.component(.year, from: $0.date)
            let m = calendar.component(.month, from: $0.date)
            return !(y == year && m == month)
        }

        // 보유한 달 수 계산
        let months = Set(pastExpenses.map {
            let y = calendar.component(.year, from: $0.date)
            let m = calendar.component(.month, from: $0.date)
            return "\(y)-\(m)"
        })
        let monthCount = max(months.count, 1)

        // 카테고리별 총합 / 달 수 = 월 평균
        var categoryTotals: [String: Int] = [:]
        for expense in pastExpenses {
            categoryTotals[expense.category.name, default: 0] += expense.amount
        }

        return categoryTotals.mapValues { $0 / monthCount }
    }

    // MARK: - Private helpers (predictDaily)

    /// 같은 주차 + 같은 요일에 해당하는 지출의 월 평균
    private func weekOfMonthAndWeekdayAverage(expenses: [Expense], weekOfMonth: Int, weekday: Int) -> Int? {
        let calendar = Calendar.current
        let matched = expenses.filter {
            calendar.component(.weekOfMonth, from: $0.date) == weekOfMonth &&
            calendar.component(.weekday, from: $0.date) == weekday
        }
        guard !matched.isEmpty else { return nil }

        // 같은 주차+요일이 등장한 월 수로 나눠 평균
        let months = Set(matched.map {
            let y = calendar.component(.year, from: $0.date)
            let m = calendar.component(.month, from: $0.date)
            return "\(y)-\(m)"
        })
        let total = matched.reduce(0) { $0 + $1.amount }
        return total / max(months.count, 1)
    }

    /// 같은 주차 전체 지출의 주 평균
    private func weekOfMonthAverage(expenses: [Expense], weekOfMonth: Int) -> Int? {
        let calendar = Calendar.current
        let matched = expenses.filter {
            calendar.component(.weekOfMonth, from: $0.date) == weekOfMonth
        }
        guard !matched.isEmpty else { return nil }

        // 같은 주차가 등장한 횟수(월별 주차)로 나눠 평균
        let weeks = Set(matched.map {
            let y = calendar.component(.year, from: $0.date)
            let m = calendar.component(.month, from: $0.date)
            return "\(y)-\(m)-\(calendar.component(.weekOfMonth, from: $0.date))"
        })
        let total = matched.reduce(0) { $0 + $1.amount }
        return total / max(weeks.count, 1)
    }

    /// 과거 데이터의 월 평균 총 지출
    private func monthlyAverage(expenses: [Expense]) -> Int {
        let calendar = Calendar.current
        let months = Set(expenses.map {
            let y = calendar.component(.year, from: $0.date)
            let m = calendar.component(.month, from: $0.date)
            return "\(y)-\(m)"
        })
        let total = expenses.reduce(0) { $0 + $1.amount }
        return total / max(months.count, 1)
    }
}
