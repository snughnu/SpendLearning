//
//  ExpenseUseCaseProtocol.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

protocol ExpenseUseCaseProtocol {
    func fetch(year: Int, month: Int) async -> [Expense]
    func delete(_ expense: Expense) async
}
