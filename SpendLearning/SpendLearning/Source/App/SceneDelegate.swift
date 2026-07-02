//
//  SceneDelegate.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import UIKit
import SwiftData

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
            container = try ModelContainer(for: ExpenseModel.self, CategoryModel.self)
        } catch {
            container = try! ModelContainer(
                for: ExpenseModel.self, CategoryModel.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        }
        let modelContext = ModelContext(container)

        let categoryRepository = SwiftDataCategoryRepository(modelContext: modelContext)
        let categoryUseCase = CategoryUseCase(repository: categoryRepository)

        let expenseRepository = SwiftDataExpenseRepository(modelContext: modelContext, categoryRepository: categoryRepository)
        let expenseUseCase = ExpenseUseCase(repository: expenseRepository)

        let homeViewModel = HomeViewModel(expenseUseCase: expenseUseCase)
        let homeViewController = HomeViewController(viewModel: homeViewModel, categoryUseCase: categoryUseCase)
        homeViewController.tabBarItem = UITabBarItem(
            title: "홈",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let aiViewController = AIViewController()
        aiViewController.tabBarItem = UITabBarItem(
            title: "AI",
            image: UIImage(systemName: "brain"),
            selectedImage: UIImage(systemName: "brain.fill")
        )

        let settingsViewController = SettingsViewController(categoryUseCase: categoryUseCase)
        let settingsNavController = UINavigationController(rootViewController: settingsViewController)
        settingsNavController.navigationBar.isHidden = true
        settingsNavController.tabBarItem = UITabBarItem(
            title: "설정",
            image: UIImage(systemName: "slider.horizontal.3"),
            selectedImage: UIImage(systemName: "slider.horizontal.3")
        )

        let tabBar = UITabBarController()
        tabBar.viewControllers = [homeViewController, aiViewController, settingsNavController]
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

