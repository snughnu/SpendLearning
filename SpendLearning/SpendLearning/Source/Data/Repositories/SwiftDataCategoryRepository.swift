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

    func fetchCategories() async -> [Category] {
        let descriptor = FetchDescriptor<CategoryModel>(
            sortBy: [SortDescriptor(\.order)]
        )
        let models = (try? modelContext.fetch(descriptor)) ?? []
        if models.isEmpty {
            let defaults = defaultCategories()
            defaults.forEach { modelContext.insert($0) }
            try? modelContext.save()
            return defaults.map { toCategory($0) }
        }
        let categories = models.map { toCategory($0) }
        return categories.filter { $0.isDeletable } + categories.filter { !$0.isDeletable }
    }

    func addCategory(name: String, emoji: String) async {
        let order = ((try? modelContext.fetch(FetchDescriptor<CategoryModel>()))?.count ?? 0)
        let model = CategoryModel(name: name, emoji: emoji, order: order, isDefault: false, isDeletable: true)
        modelContext.insert(model)
        try? modelContext.save()
    }

    func updateCategory(_ category: Category, name: String, emoji: String) async {
        let targetID = category.id
        let predicate = #Predicate<CategoryModel> { $0.id == targetID }
        let descriptor = FetchDescriptor<CategoryModel>(predicate: predicate)
        guard let model = try? modelContext.fetch(descriptor).first else { return }
        model.name = name
        model.emoji = emoji
        try? modelContext.save()
    }

    func deleteCategory(_ category: Category) async {
        let targetID = category.id

        let expensePredicate = #Predicate<ExpenseModel> { $0.categoryID == targetID }
        let expenseDescriptor = FetchDescriptor<ExpenseModel>(predicate: expensePredicate)
        let expenses = (try? modelContext.fetch(expenseDescriptor)) ?? []

        let fallbackID = fetchFallbackCategoryID()
        expenses.forEach { $0.categoryID = fallbackID }

        let categoryPredicate = #Predicate<CategoryModel> { $0.id == targetID }
        let categoryDescriptor = FetchDescriptor<CategoryModel>(predicate: categoryPredicate)
        guard let model = try? modelContext.fetch(categoryDescriptor).first else { return }
        modelContext.delete(model)

        try? modelContext.save()
    }

    func resetToDefault() async {
        let defaults = defaultCategories()
        let defaultIDs = Set(defaults.map { $0.id })

        let allExpenses = (try? modelContext.fetch(FetchDescriptor<ExpenseModel>())) ?? []
        let fallbackID = fetchFallbackCategoryID()
        allExpenses.forEach {
            if !defaultIDs.contains($0.categoryID) {
                $0.categoryID = fallbackID
            }
        }

        let allCategories = (try? modelContext.fetch(FetchDescriptor<CategoryModel>())) ?? []
        allCategories.forEach { modelContext.delete($0) }
        defaults.forEach { modelContext.insert($0) }

        try? modelContext.save()
    }

    func reorderCategories(_ categories: [Category]) async {
        for (index, category) in categories.enumerated() {
            let targetID = category.id
            let predicate = #Predicate<CategoryModel> { $0.id == targetID }
            let descriptor = FetchDescriptor<CategoryModel>(predicate: predicate)
            guard let model = try? modelContext.fetch(descriptor).first else { continue }
            model.order = index
        }
        try? modelContext.save()
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

    func fetchFallbackCategoryID() -> UUID {
        let predicate = #Predicate<CategoryModel> { !$0.isDeletable }
        let descriptor = FetchDescriptor<CategoryModel>(predicate: predicate)
        return (try? modelContext.fetch(descriptor).first?.id) ?? UUID()
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
