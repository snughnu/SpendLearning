//
//  ExpenseUseCaseProtocol.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

protocol ExpenseUseCaseProtocol {
    func fetch(year: Int, month: Int) async -> [Expense]
    func add(_ expense: Expense) async
    func delete(_ expense: Expense) async
}
