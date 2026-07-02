//
//  CategorySelectViewController.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import UIKit

final class CategorySelectViewController: UIViewController {

    // MARK: - UI
    private let navigationBar = CustomNavigationBar(title: "카테고리", leftButtonTitle: "취소")
    private let categoryCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )

    // MARK: - Cell Registration
    private let categoryCellRegistration = UICollectionView.CellRegistration<CategoryListCell, Category> {
        cell, _, category in
        cell.configure(category: category)
    }

    // MARK: - Properties
    private let viewModel: NewExpenseViewModel

    // MARK: - Init
    init(viewModel: NewExpenseViewModel) {
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
    }
}

// MARK: - UICollectionView
extension CategorySelectViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        Category.allCases.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        collectionView.dequeueConfiguredReusableCell(
            using: categoryCellRegistration,
            for: indexPath,
            item: Category.allCases[indexPath.item]
        )
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
        let category = Category.allCases[indexPath.item]
        viewModel.didSelectCategory(category)
        let inputVC = ExpenseInputViewController(viewModel: viewModel)
        inputVC.modalPresentationStyle = .fullScreen
        present(inputVC, animated: true)
    }
}

// MARK: - Helper
private extension CategorySelectViewController {

    func setup() {
        setupNavigationBar()
        setupSubviews()
        setupConstraints()
        setupCategoryCollectionView()
    }

    func setupNavigationBar() {
        navigationBar.onLeftAction = { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    func setupSubviews() {
        [navigationBar, categoryCollectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            categoryCollectionView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 24),
            categoryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            categoryCollectionView.heightAnchor.constraint(equalToConstant: CGFloat(Category.allCases.count) * 64),
        ])
    }

    func setupCategoryCollectionView() {
        guard let layout = categoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        categoryCollectionView.backgroundColor = .white
        categoryCollectionView.layer.cornerRadius = 16
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
    }
}
