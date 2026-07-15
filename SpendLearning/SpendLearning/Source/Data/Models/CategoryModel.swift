//
//  CategoryModel.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import Foundation
import SwiftData

@Model
final class CategoryModel {

    var id: UUID
    var name: String
    var emoji: String
    var order: Int
    var isDefault: Bool
    var isDeletable: Bool

    init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        order: Int,
        isDefault: Bool,
        isDeletable: Bool
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.order = order
        self.isDefault = isDefault
        self.isDeletable = isDeletable
    }
}
