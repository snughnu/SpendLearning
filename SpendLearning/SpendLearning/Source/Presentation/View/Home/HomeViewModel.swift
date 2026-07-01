//
//  HomeViewModel.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import Foundation
import Combine

final class HomeViewModel {

    // MARK: - Output
    @Published private(set) var currentYear: Int
    @Published private(set) var currentMonth: Int
    @Published private(set) var selectedDate: Date
    @Published private(set) var calendarDays: [CalendarDay] = []
    @Published private(set) var selectedDayExpenses: [Expense] = []
    @Published private(set) var selectedDayTotal: Int = 0
    @Published private(set) var totalAmount: Int = 0
    @Published private(set) var aiComment: String = ""
    @Published private(set) var calendarWeekCount: Int = 6

    // MARK: - Private
    private let fetchExpensesUseCase: FetchExpensesUseCase

    // MARK: - Init
    init(fetchExpensesUseCase: FetchExpensesUseCase) {
        let now = Date()
        let calendar = Calendar.current
        self.currentYear = calendar.component(.year, from: now)
        self.currentMonth = calendar.component(.month, from: now)
        self.selectedDate = calendar.startOfDay(for: now)
        self.fetchExpensesUseCase = fetchExpensesUseCase
        updateCalendar()
    }

    // MARK: - Input
    func didTapPreviousMonth() {
        if currentMonth == 1 {
            currentMonth = 12
            currentYear -= 1
        } else {
            currentMonth -= 1
        }
        updateCalendar()
    }

    func didTapNextMonth() {
        if currentMonth == 12 {
            currentMonth = 1
            currentYear += 1
        } else {
            currentMonth += 1
        }
        updateCalendar()
    }

    func didSelectYearMonth(year: Int, month: Int) {
        currentYear = year
        currentMonth = month
        updateCalendar()
    }

    func didSelectToday() {
        let today = Calendar.current.startOfDay(for: Date())
        let todayYear = Calendar.current.component(.year, from: today)
        let todayMonth = Calendar.current.component(.month, from: today)
        if todayYear != currentYear || todayMonth != currentMonth {
            currentYear = todayYear
            currentMonth = todayMonth
            updateCalendar()
        } else {
            selectedDate = today
            let expenses = fetchExpensesUseCase.execute(year: currentYear, month: currentMonth)
            updateSelectedDay(from: expenses)
        }
    }

    func didSelectDate(_ date: Date) {
        selectedDate = date
        let expenses = fetchExpensesUseCase.execute(year: currentYear, month: currentMonth)
        updateSelectedDay(from: expenses)
    }
}

// MARK: - Helper
private extension HomeViewModel {

    func updateCalendar() {
        let expenses = fetchExpensesUseCase.execute(year: currentYear, month: currentMonth)
        calendarDays = makeCalendarDays(year: currentYear, month: currentMonth, expenses: expenses)
        totalAmount = expenses.reduce(0) { $0 + $1.amount }
        aiComment = "이번 달 카페 지출만 벌써 9번째, 이쯤 되면 취미 아니야?"
        updateSelectedDay(from: expenses)
    }

    func updateSelectedDay(from expenses: [Expense]) {
        let calendar = Calendar.current
        let filtered = expenses.filter {
            guard let date = $0.date else { return false }
            return calendar.isDate(date, inSameDayAs: selectedDate)
        }
        selectedDayExpenses = filtered
        selectedDayTotal = filtered.reduce(0) { $0 + $1.amount }
    }

    func makeCalendarDays(year: Int, month: Int, expenses: [Expense]) -> [CalendarDay] {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        let calendar = Calendar.current
        guard let firstDay = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDay) else { return [] }

        let weekday = calendar.component(.weekday, from: firstDay)
        let leadingBlanks = weekday - 1
        let today = calendar.startOfDay(for: Date())

        var days: [CalendarDay] = Array(repeating: CalendarDay(date: nil, amount: nil, isToday: false), count: leadingBlanks)

        for day in range {
            components.day = day
            guard let date = calendar.date(from: components) else { continue }
            let isToday = calendar.isDate(date, inSameDayAs: today)
            let dayExpenses = expenses.filter {
                guard let expenseDate = $0.date else { return false }
                return calendar.isDate(expenseDate, inSameDayAs: date)
            }
            let amount = dayExpenses.isEmpty ? nil : dayExpenses.reduce(0) { $0 + $1.amount }
            days.append(CalendarDay(date: date, amount: amount, isToday: isToday))
        }

        let totalCells = leadingBlanks + range.count
        calendarWeekCount = Int(ceil(Double(totalCells) / 7.0))

        return days
    }
}
