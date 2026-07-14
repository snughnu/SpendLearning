//
//  ExpenseRepositoryProtocol.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import Foundation

protocol ExpenseRepositoryProtocol {
    func fetchExpenses(year: Int, month: Int) async -> [Expense]
    func fetchAllExpenses() async -> [Expense]
    func addExpense(_ expense: Expense) async
    func deleteExpense(_ expense: Expense) async
}
