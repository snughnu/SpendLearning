//
//  ExpenseModel.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import Foundation
import SwiftData

@Model
final class ExpenseModel {

    var id: UUID
    var date: Date?
    var categoryRawValue: String
    var memo: String?
    var amount: Int

    init(
        id: UUID = UUID(),
        date: Date?,
        categoryRawValue: String,
        memo: String?,
        amount: Int
    ) {
        self.id = id
        self.date = date
        self.categoryRawValue = categoryRawValue
        self.memo = memo
        self.amount = amount
    }
}
