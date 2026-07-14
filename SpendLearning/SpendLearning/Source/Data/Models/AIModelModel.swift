//
//  AIModelModel.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

import Foundation
import SwiftData

@Model
final class AIModelModel {

    var id: String
    var dataCount: Int
    var accuracy: Float?
    var createdAt: Date

    init(
        id: String,
        dataCount: Int,
        accuracy: Float?,
        createdAt: Date
    ) {
        self.id = id
        self.dataCount = dataCount
        self.accuracy = accuracy
        self.createdAt = createdAt
    }
}
