//
//  SceneDelegate.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import UIKit
import SwiftData
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = makeTabBarController()
        window?.makeKeyAndVisible()
    }

    private func makeTabBarController() -> UITabBarController {
        let container: ModelContainer
        do {
            container = try ModelContainer(for: ExpenseModel.self, CategoryModel.self, PredictionModel.self)
        } catch {
            // SwiftData 마이그레이션 실패 시 메모리 전용 스토어로 폴백한다.
            // 이 경로를 타면 기존에 저장된 사용자 데이터(지출/카테고리/예측 모델)가 이번 실행에서 보이지 않는다.
            // 스키마 변경 후 이 로그가 찍히면 VersionedSchema/SchemaMigrationPlan 도입을 검토할 것.
            print("⚠️ ModelContainer 생성 실패, 메모리 전용으로 폴백: \(error)")
            container = try! ModelContainer(
                for: ExpenseModel.self, CategoryModel.self, PredictionModel.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        }
        let modelContext = ModelContext(container)

        let categoryRepository = SwiftDataCategoryRepository(modelContext: modelContext)
        let categoryUseCase = CategoryUseCase(repository: categoryRepository)

//        let expenseRepository = MockExpenseRepository()
        let expenseRepository = SwiftDataExpenseRepository(modelContext: modelContext, categoryRepository: categoryRepository)
        let expenseUseCase = ExpenseUseCase(repository: expenseRepository)

        let homeViewModel = HomeViewModel(expenseUseCase: expenseUseCase)
        let homeViewController = HomeViewController(viewModel: homeViewModel, categoryUseCase: categoryUseCase)
        homeViewController.tabBarItem = UITabBarItem(
            title: "홈",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let predictionUseCase = PredictionUseCase(repository: SwiftDataPredictionRepository(modelContext: modelContext, expenseRepository: expenseRepository), expenseRepository: expenseRepository)
        let predictionViewModel = PredictionViewModel(expenseUseCase: expenseUseCase, predictionUseCase: predictionUseCase)
        let predictionViewController = UIHostingController(rootView: PredictionView(viewModel: predictionViewModel))
        predictionViewController.tabBarItem = UITabBarItem(
            title: "예측",
            image: UIImage(systemName: "brain"),
            selectedImage: UIImage(systemName: "brain.fill")
        )

        let settingsViewController = SettingsViewController(categoryUseCase: categoryUseCase)
        settingsViewController.tabBarItem = UITabBarItem(
            title: "설정",
            image: UIImage(systemName: "slider.horizontal.3"),
            selectedImage: UIImage(systemName: "slider.horizontal.3")
        )

        let tabBar = UITabBarController()
        tabBar.viewControllers = [homeViewController, predictionViewController, settingsViewController]
        tabBar.tabBar.tintColor = .DesignSystem.accent

        return tabBar
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

