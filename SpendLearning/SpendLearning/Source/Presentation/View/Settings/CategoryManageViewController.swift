//
//  CategoryManageViewController.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import UIKit
import Combine

final class CategoryManageViewController: UIViewController {

    // MARK: - UI
    private let navigationBar = CustomNavigationBar(
        title: "카테고리 관리", leftButtonTitle: "뒤로", rightButtonTitle: "초기화"
    )
    private let categoryCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    private let addButton = UIButton()

    // MARK: - Constraints
    private var collectionHeightConstraint: NSLayoutConstraint!

    // MARK: - Cell Registration
    private let categoryCellRegistration = UICollectionView.CellRegistration<SettingsCategoryCell, Category> {
        cell, _, category in
        cell.configure(category: category)
    }

    // MARK: - Properties
    private let viewModel: SettingsViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .DesignSystem.background
        setup()
        bind()
        loadCategories()
    }
}

// MARK: - Bind
private extension CategoryManageViewController {

    func bind() {
        viewModel.$categories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] categories in
                guard let self else { return }
                self.collectionHeightConstraint.constant = CGFloat(categories.count) * 64
                self.categoryCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - UICollectionView
extension CategoryManageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.categories.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueConfiguredReusableCell(
            using: categoryCellRegistration,
            for: indexPath,
            item: viewModel.categories[indexPath.item]
        )
        cell.onDelete = { [weak self] in
            self?.didTapDelete(at: indexPath.item)
        }
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 64)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let category = viewModel.categories[indexPath.item]
        presentEditSheet(category: category)
    }
}

// MARK: - Helper
private extension CategoryManageViewController {

    func setup() {
        setupNavigationBar()
        setupSubviews()
        setupAddButton()
        setupConstraints()
        setupCategoryCollectionView()
    }

    func setupNavigationBar() {
        navigationBar.onLeftAction = { [weak self] in
            self?.dismiss(animated: true)
        }
        navigationBar.onRightAction = { [weak self] in
            self?.didTapReset()
        }
    }

    func setupSubviews() {
        [navigationBar, categoryCollectionView, addButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    func setupAddButton() {
        var addConfig = UIButton.Configuration.plain()
        addConfig.title = "+ 카테고리 추가"
        addConfig.baseForegroundColor = .DesignSystem.accent
        addConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            return a
        }
        addButton.configuration = addConfig
        addButton.addAction(UIAction { [weak self] _ in
            self?.presentEditSheet(category: nil)
        }, for: .touchUpInside)
    }

    func setupConstraints() {
        collectionHeightConstraint = categoryCollectionView.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            categoryCollectionView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 24),
            categoryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionHeightConstraint,

            addButton.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 4),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        ])
    }

    func setupCategoryCollectionView() {
        guard let layout = categoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        categoryCollectionView.backgroundColor = .DesignSystem.surface
        categoryCollectionView.layer.cornerRadius = 16
        categoryCollectionView.isScrollEnabled = false
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
    }

    func loadCategories() {
        Task {
            await viewModel.loadCategories()
        }
    }

    func didTapDelete(at index: Int) {
        Task {
            await viewModel.deleteCategory(at: index)
        }
    }

    func didTapReset() {
        let alert = UIAlertController(
            title: "카테고리 초기화",
            message: "기본 카테고리 10개로 되돌립니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "초기화", style: .destructive) { [weak self] _ in
            Task {
                await self?.viewModel.resetCategories()
            }
        })
        present(alert, animated: true)
    }

    func presentEditSheet(category: Category?) {
        let editVC = CategoryEditViewController(
            category: category,
            onSave: { [weak self] name, emoji in
                Task {
                    if let category {
                        await self?.viewModel.updateCategory(category, name: name, emoji: emoji)
                    } else {
                        await self?.viewModel.addCategory(name: name, emoji: emoji)
                    }
                }
            }
        )
        if let sheet = editVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        present(editVC, animated: true)
    }
}
