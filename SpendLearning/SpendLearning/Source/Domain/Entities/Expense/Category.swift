//
//  Category.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import Foundation

struct Category: Identifiable {
    let id: UUID
    var name: String
    var emoji: String
    var isDeletable: Bool

    var displayName: String { name }

    init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        isDeletable: Bool = true
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.isDeletable = isDeletable
    }
}
