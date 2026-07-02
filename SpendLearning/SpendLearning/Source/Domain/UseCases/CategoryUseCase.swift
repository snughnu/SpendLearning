//
//  CategoryUseCase.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import Foundation

final class CategoryUseCase: CategoryUseCaseProtocol {

    private let repository: CategoryRepositoryProtocol

    init(repository: CategoryRepositoryProtocol) {
        self.repository = repository
    }

    func fetchCategories() async -> [Category] {
        await repository.fetchCategories()
    }

    func addCategory(name: String, emoji: String) async {
        await repository.addCategory(name: name, emoji: emoji)
    }

    func updateCategory(_ category: Category, name: String, emoji: String) async {
        await repository.updateCategory(category, name: name, emoji: emoji)
    }

    func deleteCategory(_ category: Category) async {
        await repository.deleteCategory(category)
    }

    func resetToDefault() async {
        await repository.resetToDefault()
    }

    func reorderCategories(_ categories: [Category]) async {
        await repository.reorderCategories(categories)
    }
}
