//
//  MockExpenseRepository.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import Foundation

final class MockExpenseRepository: ExpenseRepositoryProtocol {

    private var expenses: [Expense] = {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)

        let food = Category(name: "식비", emoji: "🍚")
        let cafe = Category(name: "카페/간식", emoji: "☕️")
        let transport = Category(name: "교통", emoji: "🚌")
        let shopping = Category(name: "쇼핑", emoji: "🛍️")
        let medical = Category(name: "의료/건강", emoji: "💊")

        // 특정 달의 특정 일 날짜 생성
        func date(monthOffset: Int, day: Int) -> Date {
            let targetMonth = month + monthOffset
            let targetYear = year + (targetMonth - 1) / 12
            var components = DateComponents()
            components.year = targetYear
            components.month = ((targetMonth - 1 + 12) % 12) + 1
            components.day = day
            return calendar.date(from: components)!
        }

        // 오늘 기준 N주 전, 특정 요일 날짜 생성 (weekday: 1=일, 2=월 ... 7=토)
        func dateByWeekday(weeksAgo: Int, weekday: Int) -> Date {
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: now)!
            let currentWeekday = calendar.component(.weekday, from: weekStart)
            let diff = weekday - currentWeekday
            return calendar.date(byAdding: .day, value: diff, to: weekStart)!
        }

        // MARK: - 이번 달 일반 지출
        let thisMonth: [Expense] = [
            Expense(date: date(monthOffset: 0, day: 1), category: food, memo: "김밥천국", amount: 8500),
            Expense(date: date(monthOffset: 0, day: 3), category: cafe, memo: "스타벅스", amount: 6000),
            Expense(date: date(monthOffset: 0, day: 8), category: transport, memo: "택시", amount: 12000),
            Expense(date: date(monthOffset: 0, day: 10), category: shopping, memo: "다이소", amount: 15000),
            Expense(date: date(monthOffset: 0, day: 10), category: food, memo: "한식당", amount: 12000),
            Expense(date: date(monthOffset: 0, day: 10), category: medical, memo: "약국", amount: 8500),
        ]

        // MARK: - 이상 지출 감지용
        // 최근 4주 카페 주 평균 약 6,000원 → 이번 주 20,000원으로 1.5배 초과
        let abnormalThisWeek: [Expense] = [
            Expense(date: dateByWeekday(weeksAgo: 0, weekday: 2), category: cafe, memo: "스타벅스", amount: 20000),
        ]
        let abnormalPast: [Expense] = [
            Expense(date: dateByWeekday(weeksAgo: 1, weekday: 2), category: cafe, memo: "스타벅스", amount: 6000),
            Expense(date: dateByWeekday(weeksAgo: 2, weekday: 2), category: cafe, memo: "스타벅스", amount: 5500),
            Expense(date: dateByWeekday(weeksAgo: 3, weekday: 2), category: cafe, memo: "스타벅스", amount: 6500),
            Expense(date: dateByWeekday(weeksAgo: 4, weekday: 2), category: cafe, memo: "스타벅스", amount: 6000),
        ]

        // MARK: - 지출 예고용
        // 최근 3주 연속 목요일(5)에 식비 지출 → 이번 주 목요일 예고
        let forecastPast: [Expense] = [
            Expense(date: dateByWeekday(weeksAgo: 1, weekday: 5), category: food, memo: "점심 정기모임", amount: 15000),
            Expense(date: dateByWeekday(weeksAgo: 2, weekday: 5), category: food, memo: "점심 정기모임", amount: 14000),
            Expense(date: dateByWeekday(weeksAgo: 3, weekday: 5), category: food, memo: "점심 정기모임", amount: 16000),
        ]

        // MARK: - 미기록 감지용
        // 최근 3주 연속 일요일(1)에 교통비 지출 → 이번 주 일요일 기록 없음
        let unrecordedPast: [Expense] = [
            Expense(date: dateByWeekday(weeksAgo: 1, weekday: 1), category: transport, memo: "일요일 택시", amount: 12000),
            Expense(date: dateByWeekday(weeksAgo: 2, weekday: 1), category: transport, memo: "일요일 택시", amount: 11000),
            Expense(date: dateByWeekday(weeksAgo: 3, weekday: 1), category: transport, memo: "일요일 택시", amount: 13000),
        ]

        // MARK: - 과거 일반 지출
        let oneMonthAgo: [Expense] = [
            Expense(date: date(monthOffset: -1, day: 2), category: food, memo: "김밥천국", amount: 7500),
            Expense(date: date(monthOffset: -1, day: 5), category: cafe, memo: "스타벅스", amount: 6000),
            Expense(date: date(monthOffset: -1, day: 9), category: transport, memo: "택시", amount: 11000),
            Expense(date: date(monthOffset: -1, day: 11), category: shopping, memo: "다이소", amount: 13000),
            Expense(date: date(monthOffset: -1, day: 11), category: food, memo: "한식당", amount: 11000),
            Expense(date: date(monthOffset: -1, day: 14), category: cafe, memo: "투썸플레이스", amount: 5800),
            Expense(date: date(monthOffset: -1, day: 16), category: food, memo: "점심", amount: 8500),
            Expense(date: date(monthOffset: -1, day: 18), category: medical, memo: "약국", amount: 7500),
            Expense(date: date(monthOffset: -1, day: 20), category: transport, memo: "지하철", amount: 4500),
            Expense(date: date(monthOffset: -1, day: 22), category: food, memo: "저녁", amount: 55000),
            Expense(date: date(monthOffset: -1, day: 25), category: cafe, memo: "카페", amount: 14000),
            Expense(date: date(monthOffset: -1, day: 27), category: shopping, memo: "쿠팡", amount: 98000),
            Expense(date: date(monthOffset: -1, day: 29), category: food, memo: "외식", amount: 28000),
        ]

        let twoMonthsAgo: [Expense] = [
            Expense(date: date(monthOffset: -2, day: 1), category: food, memo: "김밥천국", amount: 8000),
            Expense(date: date(monthOffset: -2, day: 4), category: cafe, memo: "스타벅스", amount: 5500),
            Expense(date: date(monthOffset: -2, day: 7), category: transport, memo: "택시", amount: 13000),
            Expense(date: date(monthOffset: -2, day: 10), category: food, memo: "한식당", amount: 10500),
            Expense(date: date(monthOffset: -2, day: 12), category: shopping, memo: "올리브영", amount: 22000),
            Expense(date: date(monthOffset: -2, day: 15), category: cafe, memo: "투썸플레이스", amount: 6200),
            Expense(date: date(monthOffset: -2, day: 17), category: food, memo: "점심", amount: 9500),
            Expense(date: date(monthOffset: -2, day: 19), category: medical, memo: "병원", amount: 15000),
            Expense(date: date(monthOffset: -2, day: 21), category: transport, memo: "지하철", amount: 4500),
            Expense(date: date(monthOffset: -2, day: 23), category: food, memo: "저녁", amount: 48000),
            Expense(date: date(monthOffset: -2, day: 26), category: cafe, memo: "카페", amount: 12000),
            Expense(date: date(monthOffset: -2, day: 28), category: shopping, memo: "쿠팡", amount: 75000),
        ]

        let threeMonthsAgo: [Expense] = [
            Expense(date: date(monthOffset: -3, day: 2), category: food, memo: "김밥천국", amount: 7000),
            Expense(date: date(monthOffset: -3, day: 5), category: cafe, memo: "스타벅스", amount: 6000),
            Expense(date: date(monthOffset: -3, day: 8), category: transport, memo: "택시", amount: 10000),
            Expense(date: date(monthOffset: -3, day: 11), category: food, memo: "한식당", amount: 12000),
            Expense(date: date(monthOffset: -3, day: 13), category: medical, memo: "약국", amount: 8000),
            Expense(date: date(monthOffset: -3, day: 16), category: cafe, memo: "투썸플레이스", amount: 5500),
            Expense(date: date(monthOffset: -3, day: 18), category: shopping, memo: "다이소", amount: 18000),
            Expense(date: date(monthOffset: -3, day: 20), category: food, memo: "점심", amount: 8000),
            Expense(date: date(monthOffset: -3, day: 22), category: transport, memo: "지하철", amount: 4500),
            Expense(date: date(monthOffset: -3, day: 24), category: food, memo: "저녁", amount: 42000),
            Expense(date: date(monthOffset: -3, day: 27), category: cafe, memo: "카페", amount: 11000),
            Expense(date: date(monthOffset: -3, day: 29), category: shopping, memo: "쿠팡", amount: 65000),
        ]

        let fourMonthsAgo: [Expense] = [
            Expense(date: date(monthOffset: -4, day: 1), category: food, memo: "김밥천국", amount: 8500),
            Expense(date: date(monthOffset: -4, day: 4), category: cafe, memo: "스타벅스", amount: 5800),
            Expense(date: date(monthOffset: -4, day: 7), category: transport, memo: "택시", amount: 12000),
            Expense(date: date(monthOffset: -4, day: 9), category: food, memo: "한식당", amount: 11500),
            Expense(date: date(monthOffset: -4, day: 12), category: shopping, memo: "올리브영", amount: 19000),
            Expense(date: date(monthOffset: -4, day: 14), category: cafe, memo: "투썸플레이스", amount: 6000),
            Expense(date: date(monthOffset: -4, day: 17), category: food, memo: "점심", amount: 9000),
            Expense(date: date(monthOffset: -4, day: 19), category: medical, memo: "병원", amount: 12000),
            Expense(date: date(monthOffset: -4, day: 21), category: transport, memo: "지하철", amount: 4500),
            Expense(date: date(monthOffset: -4, day: 23), category: food, memo: "저녁", amount: 51000),
            Expense(date: date(monthOffset: -4, day: 26), category: cafe, memo: "카페", amount: 13000),
            Expense(date: date(monthOffset: -4, day: 28), category: shopping, memo: "쿠팡", amount: 88000),
        ]

        let fiveMonthsAgo: [Expense] = [
            Expense(date: date(monthOffset: -5, day: 2), category: food, memo: "김밥천국", amount: 7500),
            Expense(date: date(monthOffset: -5, day: 5), category: cafe, memo: "스타벅스", amount: 6200),
            Expense(date: date(monthOffset: -5, day: 8), category: transport, memo: "택시", amount: 11500),
            Expense(date: date(monthOffset: -5, day: 10), category: food, memo: "한식당", amount: 10000),
            Expense(date: date(monthOffset: -5, day: 13), category: shopping, memo: "다이소", amount: 14000),
            Expense(date: date(monthOffset: -5, day: 15), category: cafe, memo: "투썸플레이스", amount: 5500),
            Expense(date: date(monthOffset: -5, day: 18), category: food, memo: "점심", amount: 8500),
            Expense(date: date(monthOffset: -5, day: 20), category: medical, memo: "약국", amount: 9000),
            Expense(date: date(monthOffset: -5, day: 22), category: transport, memo: "지하철", amount: 4500),
            Expense(date: date(monthOffset: -5, day: 24), category: food, memo: "저녁", amount: 45000),
            Expense(date: date(monthOffset: -5, day: 27), category: cafe, memo: "카페", amount: 12500),
            Expense(date: date(monthOffset: -5, day: 29), category: shopping, memo: "쿠팡", amount: 72000),
        ]

        return thisMonth
            + abnormalThisWeek
            + abnormalPast
            + forecastPast
            + unrecordedPast
            + oneMonthAgo
            + twoMonthsAgo
            + threeMonthsAgo
            + fourMonthsAgo
            + fiveMonthsAgo
    }()

    func fetchExpenses(year: Int, month: Int) async -> [Expense] {
        let calendar = Calendar.current
        return expenses.filter {
            let y = calendar.component(.year, from: $0.date)
            let m = calendar.component(.month, from: $0.date)
            return y == year && m == month
        }
    }

    func fetchAllExpenses() async -> [Expense] {
        expenses
    }

    func deleteExpense(_ expense: Expense) async {
        expenses.removeAll { $0.id == expense.id }
    }

    func addExpense(_ expense: Expense) async {
        expenses.append(expense)
    }
}
