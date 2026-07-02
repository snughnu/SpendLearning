//
//  SettingsViewModel.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import Foundation
import Combine

@MainActor
final class SettingsViewModel {

    // MARK: - Output
    @Published private(set) var categories: [Category] = []

    // MARK: - Private
    private let categoryUseCase: CategoryUseCaseProtocol

    // MARK: - Init
    init(categoryUseCase: CategoryUseCaseProtocol) {
        self.categoryUseCase = categoryUseCase
    }

    // MARK: - Input
    func loadCategories() async {
        categories = await categoryUseCase.fetchCategories()
    }

    func addCategory(name: String, emoji: String) async {
        await categoryUseCase.addCategory(name: name, emoji: emoji)
        categories = await categoryUseCase.fetchCategories()
    }

    func updateCategory(_ category: Category, name: String, emoji: String) async {
        await categoryUseCase.updateCategory(category, name: name, emoji: emoji)
        categories = await categoryUseCase.fetchCategories()
    }

    func deleteCategory(at index: Int) async {
        let category = categories[index]
        await categoryUseCase.deleteCategory(category)
        categories = await categoryUseCase.fetchCategories()
    }

    func resetCategories() async {
        await categoryUseCase.resetToDefault()
        categories = await categoryUseCase.fetchCategories()
    }
}
