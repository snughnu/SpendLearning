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
    var date: Date
    var categoryID: UUID
    var memo: String?
    var amount: Int

    init(
        id: UUID = UUID(),
        date: Date,
        categoryID: UUID,
        memo: String?,
        amount: Int
    ) {
        self.id = id
        self.date = date
        self.categoryID = categoryID
        self.memo = memo
        self.amount = amount
    }
}
