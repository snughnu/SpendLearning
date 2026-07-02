//
//  SettingsViewModelTests.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import Testing

@Suite("SettingsViewModel")
@MainActor
struct SettingsViewModelTests {

    @Test("loadCategories 호출 후 categories가 채워진다")
    func loadCategoriesFillsCategories() async {
        let stub = StubCategoryUseCase()
        let category = Category(name: "식비", emoji: "🍚")
        stub.stubbedCategories = [category]
        let sut = SettingsViewModel(categoryUseCase: stub)

        await sut.loadCategories()

        #expect(sut.categories.count == 1)
        #expect(sut.categories.first?.id == category.id)
    }

    @Test("addCategory 호출 후 categories가 갱신된다")
    func addCategoryRefreshesCategories() async {
        let stub = StubCategoryUseCase()
        let sut = SettingsViewModel(categoryUseCase: stub)
        stub.stubbedCategories = [Category(name: "카페", emoji: "☕️")]

        await sut.addCategory(name: "카페", emoji: "☕️")

        #expect(sut.categories.count == 1)
        #expect(sut.categories.first?.name == "카페")
    }

    @Test("updateCategory 호출 후 categories가 갱신된다")
    func updateCategoryRefreshesCategories() async {
        let stub = StubCategoryUseCase()
        let original = Category(name: "식비", emoji: "🍚")
        stub.stubbedCategories = [Category(name: "외식", emoji: "🍖")]
        let sut = SettingsViewModel(categoryUseCase: stub)

        await sut.updateCategory(original, name: "외식", emoji: "🍖")

        #expect(sut.categories.first?.name == "외식")
    }

    @Test("deleteCategory(at:) 호출 후 categories가 갱신된다")
    func deleteCategoryRefreshesCategories() async {
        let stub = StubCategoryUseCase()
        let category = Category(name: "쇼핑", emoji: "🛍️")
        stub.stubbedCategories = [category]
        let sut = SettingsViewModel(categoryUseCase: stub)
        await sut.loadCategories()

        stub.stubbedCategories = []
        await sut.deleteCategory(at: 0)

        #expect(sut.categories.isEmpty)
    }

    @Test("resetCategories 호출 후 categories가 갱신된다")
    func resetCategoriesRefreshesCategories() async {
        let stub = StubCategoryUseCase()
        let sut = SettingsViewModel(categoryUseCase: stub)
        stub.stubbedCategories = [
            Category(name: "식비", emoji: "🍚"),
            Category(name: "교통", emoji: "🚌"),
        ]

        await sut.resetCategories()

        #expect(sut.categories.count == 2)
    }

    @Test("reorderCategories 호출 후 categories가 갱신된 순서로 반영된다")
    func reorderCategoriesRefreshesCategories() async {
        let stub = StubCategoryUseCase()
        let first = Category(name: "교통", emoji: "🚌")
        let second = Category(name: "식비", emoji: "🍚")
        stub.stubbedCategories = [first, second]
        let sut = SettingsViewModel(categoryUseCase: stub)

        await sut.reorderCategories([first, second])

        #expect(sut.categories.first?.id == first.id)
        #expect(sut.categories.last?.id == second.id)
    }
}

// MARK: - Stub

final class StubCategoryUseCase: CategoryUseCaseProtocol {
    var stubbedCategories: [Category] = []

    func fetchCategories() async -> [Category] { stubbedCategories }
    func addCategory(name: String, emoji: String) async {}
    func updateCategory(_ category: Category, name: String, emoji: String) async {}
    func deleteCategory(_ category: Category) async {}
    func resetToDefault() async {}
    func reorderCategories(_ categories: [Category]) async {}
}
