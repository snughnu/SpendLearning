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
    @Published private(set) var fetchError: Error? = nil
    @Published private(set) var saveError: Error? = nil

    // MARK: - Private
    private let categoryUseCase: CategoryUseCaseProtocol

    // MARK: - Init
    init(categoryUseCase: CategoryUseCaseProtocol) {
        self.categoryUseCase = categoryUseCase
    }

    // MARK: - Input
    func loadCategories() async {
        do {
            categories = try await categoryUseCase.fetchCategories()
            fetchError = nil
        } catch {
            fetchError = error
        }
    }

    func addCategory(name: String, emoji: String) async {
        do {
            try await categoryUseCase.addCategory(name: name, emoji: emoji)
            categories = (try? await categoryUseCase.fetchCategories()) ?? categories
        } catch {
            saveError = error
            await loadCategories()
        }
    }

    func updateCategory(_ category: Category, name: String, emoji: String) async {
        do {
            try await categoryUseCase.updateCategory(category, name: name, emoji: emoji)
            categories = (try? await categoryUseCase.fetchCategories()) ?? categories
        } catch {
            saveError = error
            await loadCategories()
        }
    }

    func deleteCategory(at index: Int) async {
        let category = categories[index]
        do {
            try await categoryUseCase.deleteCategory(category)
            categories = (try? await categoryUseCase.fetchCategories()) ?? categories
        } catch {
            saveError = error
            await loadCategories()
        }
    }

    func resetCategories() async {
        do {
            try await categoryUseCase.resetToDefault()
            categories = (try? await categoryUseCase.fetchCategories()) ?? categories
        } catch {
            saveError = error
            await loadCategories()
        }
    }

    func reorderCategories(_ categories: [Category]) async {
        do {
            try await categoryUseCase.reorderCategories(categories)
            self.categories = (try? await categoryUseCase.fetchCategories()) ?? self.categories
        } catch {
            saveError = error
            await loadCategories()
        }
    }
}
