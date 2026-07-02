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
    private let scrollView = UIScrollView()
    private let scrollContentView = UIView()
    private let categoryTableView = UITableView()

    // MARK: - Constraints
    private var tableHeightConstraint: NSLayoutConstraint!

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
        loadCategories()
    }
}

// MARK: - UITableView
extension CategorySelectViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingsCategoryCell.reuseIdentifier,
            for: indexPath
        ) as! SettingsCategoryCell
        cell.configure(category: viewModel.categories[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = viewModel.categories[indexPath.row]
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
        setupCategoryTableView()
    }

    func setupNavigationBar() {
        navigationBar.onLeftAction = { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    func setupSubviews() {
        scrollView.showsVerticalScrollIndicator = false

        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(scrollContentView)

        categoryTableView.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.addSubview(categoryTableView)

        [navigationBar, scrollView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    func setupConstraints() {
        tableHeightConstraint = categoryTableView.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            categoryTableView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 24),
            categoryTableView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20),
            categoryTableView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20),
            categoryTableView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -24),
            tableHeightConstraint,
        ])
    }

    func setupCategoryTableView() {
        categoryTableView.backgroundColor = .DesignSystem.surface
        categoryTableView.layer.cornerRadius = 16
        categoryTableView.isScrollEnabled = false
        categoryTableView.separatorStyle = .none
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        categoryTableView.register(
            SettingsCategoryCell.self,
            forCellReuseIdentifier: SettingsCategoryCell.reuseIdentifier
        )
    }

    func loadCategories() {
        Task {
            await viewModel.loadCategories()
            tableHeightConstraint.constant = CGFloat(viewModel.categories.count) * 64
            categoryTableView.reloadData()
        }
    }
}
