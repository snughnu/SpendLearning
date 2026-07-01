//
//  Expense.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import Foundation

struct Expense {
    let id: UUID
    let date: Date?
    let category: Category
    let memo: String?
    let amount: Int

    init(id: UUID = UUID(), date: Date?, category: Category, memo: String?, amount: Int) {
        self.id = id
        self.date = date
        self.category = category
        self.memo = memo
        self.amount = amount
    }
}
