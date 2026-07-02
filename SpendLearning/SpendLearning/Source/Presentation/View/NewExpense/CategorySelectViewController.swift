//
//  CategorySelectViewController.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import UIKit

final class CategorySelectViewController: UIViewController {

    // MARK: - UI
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
        let category = Category.allCases[indexPath.item]
        return collectionView.dequeueConfiguredReusableCell(
            using: categoryCellRegistration,
            for: indexPath,
            item: category
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 64)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let category = Category.allCases[indexPath.item]
        viewModel.didSelectCategory(category)
        let inputVC = ExpenseInputViewController(viewModel: viewModel)
        navigationController?.pushViewController(inputVC, animated: true)
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
        title = "카테고리"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(didTapCancel)
        )
    }

    func setupSubviews() {
        categoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoryCollectionView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            categoryCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            categoryCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            categoryCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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

    @objc func didTapCancel() {
        dismiss(animated: true)
    }
}
