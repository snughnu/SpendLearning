//
//  CategoryUseCaseProtocol.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import Foundation

protocol CategoryUseCaseProtocol {
    func fetchCategories() async throws -> [Category]
    func addCategory(name: String, emoji: String) async throws
    func updateCategory(_ category: Category, name: String, emoji: String) async throws
    func deleteCategory(_ category: Category) async throws
    func resetToDefault() async throws
    func reorderCategories(_ categories: [Category]) async throws
}
