//
//  SwiftDataCategoryRepository.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import Foundation
import SwiftData

final class SwiftDataCategoryRepository: CategoryRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchCategories() async throws -> [Category] {
        let descriptor = FetchDescriptor<CategoryModel>(
            sortBy: [SortDescriptor(\.order)]
        )
        let models = try modelContext.fetch(descriptor)
        if models.isEmpty {
            let defaults = defaultCategories()
            defaults.forEach { modelContext.insert($0) }
            try modelContext.save()
            return defaults.map { toCategory($0) }
        }
        return models.map { toCategory($0) }
    }

    func addCategory(name: String, emoji: String) async throws {
        let count = try modelContext.fetch(FetchDescriptor<CategoryModel>()).count
        let model = CategoryModel(name: name, emoji: emoji, order: count, isDefault: false, isDeletable: true)
        modelContext.insert(model)
        try modelContext.save()
    }

    func updateCategory(_ category: Category, name: String, emoji: String) async throws {
        let targetID = category.id
        let predicate = #Predicate<CategoryModel> { $0.id == targetID }
        let descriptor = FetchDescriptor<CategoryModel>(predicate: predicate)
        guard let model = try modelContext.fetch(descriptor).first else { return }
        model.name = name
        model.emoji = emoji
        try modelContext.save()
    }

    func deleteCategory(_ category: Category) async throws {
        let targetID = category.id

        let expensePredicate = #Predicate<ExpenseModel> { $0.categoryID == targetID }
        let expenses = try modelContext.fetch(FetchDescriptor<ExpenseModel>(predicate: expensePredicate))
        let fallbackID = try fetchFallbackCategoryID()
        expenses.forEach { $0.categoryID = fallbackID }

        let categoryPredicate = #Predicate<CategoryModel> { $0.id == targetID }
        guard let model = try modelContext.fetch(FetchDescriptor<CategoryModel>(predicate: categoryPredicate)).first else { return }
        modelContext.delete(model)

        try modelContext.save()
    }

    func resetToDefault() async throws {
        // 기존 DB에서 isDefault인 카테고리 ID 수집
        let existingDefaultPredicate = #Predicate<CategoryModel> { $0.isDefault }
        let existingDefaults = try modelContext.fetch(FetchDescriptor<CategoryModel>(predicate: existingDefaultPredicate))
        let existingDefaultIDs = Set(existingDefaults.map { $0.id })

        // 커스텀 카테고리에 속한 지출만 기타로 변경
        let fallbackID = try fetchFallbackCategoryID()
        let allExpenses = try modelContext.fetch(FetchDescriptor<ExpenseModel>())
        allExpenses.forEach {
            if !existingDefaultIDs.contains($0.categoryID) {
                $0.categoryID = fallbackID
            }
        }

        // 커스텀 카테고리만 삭제
        let customPredicate = #Predicate<CategoryModel> { !$0.isDefault }
        let customCategories = try modelContext.fetch(FetchDescriptor<CategoryModel>(predicate: customPredicate))
        customCategories.forEach { modelContext.delete($0) }

        // 기본 카테고리 order 복구
        let defaultOrderByName = Dictionary(uniqueKeysWithValues: defaultCategories().map { ($0.name, $0.order) })
        existingDefaults.forEach {
            if let order = defaultOrderByName[$0.name] {
                $0.order = order
            }
        }

        try modelContext.save()
    }

    func reorderCategories(_ categories: [Category]) async throws {
        let allModels = try modelContext.fetch(FetchDescriptor<CategoryModel>())
        let modelByID = Dictionary(uniqueKeysWithValues: allModels.map { ($0.id, $0) })
        for (index, category) in categories.enumerated() {
            modelByID[category.id]?.order = index
        }
        try modelContext.save()
    }
}

// MARK: - Mapping
private extension SwiftDataCategoryRepository {

    func toCategory(_ model: CategoryModel) -> Category {
        Category(
            id: model.id,
            name: model.name,
            emoji: model.emoji,
            isDeletable: model.isDeletable
        )
    }

    func fetchFallbackCategoryID() throws -> UUID {
        let predicate = #Predicate<CategoryModel> { !$0.isDeletable }
        let descriptor = FetchDescriptor<CategoryModel>(predicate: predicate)
        guard let id = try modelContext.fetch(descriptor).first?.id else {
            throw CategoryRepositoryError.fallbackCategoryNotFound
        }
        return id
    }

    func defaultCategories() -> [CategoryModel] {
        [
            CategoryModel(name: "식비", emoji: "🍚", order: 0, isDefault: true, isDeletable: true),
            CategoryModel(name: "카페/간식", emoji: "☕️", order: 1, isDefault: true, isDeletable: true),
            CategoryModel(name: "교통", emoji: "🚌", order: 2, isDefault: true, isDeletable: true),
            CategoryModel(name: "쇼핑", emoji: "🛍️", order: 3, isDefault: true, isDeletable: true),
            CategoryModel(name: "여가", emoji: "🎮", order: 4, isDefault: true, isDeletable: true),
            CategoryModel(name: "통신비", emoji: "📞", order: 5, isDefault: true, isDeletable: true),
            CategoryModel(name: "의료/건강", emoji: "💊", order: 6, isDefault: true, isDeletable: true),
            CategoryModel(name: "구독", emoji: "🧾", order: 7, isDefault: true, isDeletable: true),
            CategoryModel(name: "경조사", emoji: "✉️", order: 8, isDefault: true, isDeletable: true),
            CategoryModel(name: "기타", emoji: "📦", order: 9, isDefault: true, isDeletable: false),
        ]
    }
}

enum CategoryRepositoryError: Error {
    case fallbackCategoryNotFound
}
