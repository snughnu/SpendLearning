//
//  StatisticsPredictor.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

import Foundation

final class StatisticsPredictor {

    /// 패턴으로 신뢰하기 위한 최소 표본 수
    private let minimumSampleCount = 2
    /// 패턴으로 신뢰하기 위한 변동계수(표준편차/평균) 임계값. 낮을수록 값이 일관됨을 의미
    private let coefficientOfVariationThreshold = 0.5

    // MARK: - predictDaily

    /// 이번 달 일별 예측 지출 금액을 반환한다.
    /// 폴백 순서 (각 순위는 표본이 2건 이상이고 변동계수가 임계값 이하일 때만 채택한다):
    /// 1. 과거 같은 날짜(dayOfMonth) 지출 평균 — 정기결제 등 날짜 기반 패턴
    /// 2. 데이터가 패턴으로 인정되지 않으면 → 과거 같은 요일(weekday) 지출 평균 — 습관성 소비 패턴
    /// 3. 그것도 패턴으로 인정되지 않으면 → 과거 월 평균 총액 / 이번 달 일수
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
            let dayOfMonth = calendar.component(.day, from: date)
            let weekday = calendar.component(.weekday, from: date)

            if let avg = reliableDayOfMonthAverage(expenses: pastExpenses, dayOfMonth: dayOfMonth) {
                // 1순위: 같은 날짜의 일관된 평균 (정기결제 등)
                result[day] = avg
            } else if let avg = reliableWeekdayAverage(expenses: pastExpenses, weekday: weekday) {
                // 2순위: 같은 요일의 일관된 평균 (습관성 소비)
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

    /// 같은 날짜(dayOfMonth)의 지출을 월별로 합산해, 표본이 충분하고 변동계수가 임계값 이하일 때만 평균을 반환한다.
    private func reliableDayOfMonthAverage(expenses: [Expense], dayOfMonth: Int) -> Int? {
        let calendar = Calendar.current
        let matched = expenses.filter {
            calendar.component(.day, from: $0.date) == dayOfMonth
        }
        let monthlyTotals = monthlyTotals(of: matched, calendar: calendar)
        return reliableAverage(of: monthlyTotals)
    }

    /// 같은 요일(weekday)의 지출을 주별로 합산해, 표본이 충분하고 변동계수가 임계값 이하일 때만 평균을 반환한다.
    private func reliableWeekdayAverage(expenses: [Expense], weekday: Int) -> Int? {
        let calendar = Calendar.current
        let matched = expenses.filter {
            calendar.component(.weekday, from: $0.date) == weekday
        }
        let weeklyTotals = weeklyTotals(of: matched, calendar: calendar)
        return reliableAverage(of: weeklyTotals)
    }

    /// 지출을 연-월 단위로 묶어 각 달의 합계 목록을 반환한다.
    private func monthlyTotals(of expenses: [Expense], calendar: Calendar) -> [Int] {
        Dictionary(grouping: expenses) {
            "\(calendar.component(.year, from: $0.date))-\(calendar.component(.month, from: $0.date))"
        }
        .values
        .map { group in group.reduce(0) { $0 + $1.amount } }
    }

    /// 지출을 연-주 단위로 묶어 각 주의 합계 목록을 반환한다.
    private func weeklyTotals(of expenses: [Expense], calendar: Calendar) -> [Int] {
        Dictionary(grouping: expenses) {
            "\(calendar.component(.year, from: $0.date))-\(calendar.component(.weekOfYear, from: $0.date))"
        }
        .values
        .map { group in group.reduce(0) { $0 + $1.amount } }
    }

    /// 표본이 최소 개수 이상이고, 변동계수가 임계값 이하로 일관될 때만 평균을 반환한다.
    /// 표본이 3개 이상인데 변동계수가 기준을 넘으면, 평균에서 가장 먼 값 하나를 이상치로 보고
    /// 제외한 뒤 재계산한다 — 4번 중 3번은 비슷한데 1번만 튀는 경우까지 패턴으로 인정하기 위함.
    /// 그래도 넘으면(값 자체가 전반적으로 들쭉날쭉하면) nil을 반환해 다음 순위로 폴백시킨다.
    private func reliableAverage(of samples: [Int]) -> Int? {
        guard let result = reliableAverage(of: samples, allowOutlierRemoval: true) else { return nil }
        return result
    }

    private func reliableAverage(of samples: [Int], allowOutlierRemoval: Bool) -> Int? {
        guard samples.count >= minimumSampleCount else { return nil }

        let mean = Double(samples.reduce(0, +)) / Double(samples.count)
        guard mean > 0 else { return nil }

        let variance = samples.reduce(0.0) { $0 + pow(Double($1) - mean, 2) } / Double(samples.count)
        let standardDeviation = variance.squareRoot()
        let coefficientOfVariation = standardDeviation / mean

        if coefficientOfVariation <= coefficientOfVariationThreshold {
            return Int(mean)
        }

        // 표본이 3개 이상이면, 평균에서 가장 멀리 떨어진 값 하나를 제외하고 한 번만 재시도한다.
        guard allowOutlierRemoval, samples.count >= 3,
              let farthestIndex = samples.indices.max(by: { abs(Double(samples[$0]) - mean) < abs(Double(samples[$1]) - mean) }) else {
            return nil
        }
        var reduced = samples
        reduced.remove(at: farthestIndex)
        return reliableAverage(of: reduced, allowOutlierRemoval: false)
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
