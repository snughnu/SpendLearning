//
//  CategoryUseCaseTests.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import Testing

@Suite("CategoryUseCase")
@MainActor
struct CategoryUseCaseTests {

    @Test("fetchCategories 호출 시 Repository의 fetchCategories가 호출된다")
    func fetchCategoriesCallsRepository() async throws {
        let spy = SpyCategoryRepository()
        let sut = CategoryUseCase(repository: spy)

        _ = try await sut.fetchCategories()

        #expect(spy.fetchCallCount == 1)
    }

    @Test("fetchCategories 호출 시 Repository에서 반환한 결과를 그대로 반환한다")
    func fetchCategoriesReturnsRepositoryResult() async throws {
        let spy = SpyCategoryRepository()
        let category = Category(name: "식비", emoji: "🍚")
        spy.stubbedCategories = [category]
        let sut = CategoryUseCase(repository: spy)

        let result = try await sut.fetchCategories()

        #expect(result.count == 1)
        #expect(result.first?.id == category.id)
    }

    @Test("addCategory 호출 시 Repository의 addCategory가 올바른 name/emoji로 호출된다")
    func addCategoryCallsRepositoryWithCorrectArguments() async throws {
        let spy = SpyCategoryRepository()
        let sut = CategoryUseCase(repository: spy)

        try await sut.addCategory(name: "카페", emoji: "☕️")

        #expect(spy.addCallCount == 1)
        #expect(spy.addedName == "카페")
        #expect(spy.addedEmoji == "☕️")
    }

    @Test("updateCategory 호출 시 Repository의 updateCategory가 올바른 인자로 호출된다")
    func updateCategoryCallsRepositoryWithCorrectArguments() async throws {
        let spy = SpyCategoryRepository()
        let category = Category(name: "식비", emoji: "🍚")
        let sut = CategoryUseCase(repository: spy)

        try await sut.updateCategory(category, name: "외식", emoji: "🍖")

        #expect(spy.updateCallCount == 1)
        #expect(spy.updatedCategory?.id == category.id)
        #expect(spy.updatedName == "외식")
        #expect(spy.updatedEmoji == "🍖")
    }

    @Test("deleteCategory 호출 시 Repository의 deleteCategory가 올바른 category로 호출된다")
    func deleteCategoryCallsRepositoryWithCorrectCategory() async throws {
        let spy = SpyCategoryRepository()
        let category = Category(name: "쇼핑", emoji: "🛍️")
        let sut = CategoryUseCase(repository: spy)

        try await sut.deleteCategory(category)

        #expect(spy.deleteCallCount == 1)
        #expect(spy.deletedCategory?.id == category.id)
    }

    @Test("resetToDefault 호출 시 Repository의 resetToDefault가 호출된다")
    func resetToDefaultCallsRepository() async throws {
        let spy = SpyCategoryRepository()
        let sut = CategoryUseCase(repository: spy)

        try await sut.resetToDefault()

        #expect(spy.resetCallCount == 1)
    }

    @Test("reorderCategories 호출 시 Repository의 reorderCategories가 올바른 순서로 호출된다")
    func reorderCategoriesCallsRepositoryWithCorrectOrder() async throws {
        let spy = SpyCategoryRepository()
        let first = Category(name: "식비", emoji: "🍚")
        let second = Category(name: "교통", emoji: "🚌")
        let sut = CategoryUseCase(repository: spy)

        try await sut.reorderCategories([first, second])

        #expect(spy.reorderCallCount == 1)
        #expect(spy.reorderedCategories?.first?.id == first.id)
        #expect(spy.reorderedCategories?.last?.id == second.id)
    }
}

// MARK: - Spy

final class SpyCategoryRepository: CategoryRepositoryProtocol {
    private(set) var fetchCallCount = 0
    private(set) var addCallCount = 0
    private(set) var addedName: String?
    private(set) var addedEmoji: String?
    private(set) var updateCallCount = 0
    private(set) var updatedCategory: Category?
    private(set) var updatedName: String?
    private(set) var updatedEmoji: String?
    private(set) var deleteCallCount = 0
    private(set) var deletedCategory: Category?
    private(set) var resetCallCount = 0
    private(set) var reorderCallCount = 0
    private(set) var reorderedCategories: [Category]?
    var stubbedCategories: [Category] = []

    func fetchCategories() async throws -> [Category] {
        fetchCallCount += 1
        return stubbedCategories
    }

    func addCategory(name: String, emoji: String) async throws {
        addCallCount += 1
        addedName = name
        addedEmoji = emoji
    }

    func updateCategory(_ category: Category, name: String, emoji: String) async throws {
        updateCallCount += 1
        updatedCategory = category
        updatedName = name
        updatedEmoji = emoji
    }

    func deleteCategory(_ category: Category) async throws {
        deleteCallCount += 1
        deletedCategory = category
    }

    func resetToDefault() async throws {
        resetCallCount += 1
    }

    func reorderCategories(_ categories: [Category]) async throws {
        reorderCallCount += 1
        reorderedCategories = categories
    }
}
