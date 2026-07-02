//
//  CategoryUseCaseProtocol.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import Foundation

protocol CategoryUseCaseProtocol {
    func fetchCategories() async -> [Category]
    func addCategory(name: String, emoji: String) async
    func updateCategory(_ category: Category, name: String, emoji: String) async
    func deleteCategory(_ category: Category) async
    func resetToDefault() async
}
