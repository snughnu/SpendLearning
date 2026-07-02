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
        title: "카테고리 관리", leftButtonTitle: "뒤로", rightButtonTitle: "편집"
    )
    private let scrollView = UIScrollView()
    private let scrollContentView = UIView()
    private let categoryTableView = UITableView()
    private let addButton = UIButton()
    private let resetButton = UIButton()

    // MARK: - Constraints
    private var tableHeightConstraint: NSLayoutConstraint!

    // MARK: - Properties
    private let viewModel: SettingsViewModel
    private var cancellables = Set<AnyCancellable>()
    private var isEditingMode = false

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
                self.tableHeightConstraint.constant = CGFloat(categories.count) * 64
                self.categoryTableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableView
extension CategoryManageViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.categories.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingsCategoryCell.reuseIdentifier,
            for: indexPath
        ) as! SettingsCategoryCell
        cell.configure(category: viewModel.categories[indexPath.row])
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        64
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        guard isEditingMode else { return }
        let category = viewModel.categories[indexPath.row]
        guard category.isDeletable else { return }
        presentEditSheet(category: category)
    }

    func tableView(
        _ tableView: UITableView,
        canMoveRowAt indexPath: IndexPath
    ) -> Bool {
        viewModel.categories[indexPath.row].isDeletable
    }

    func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        var reordered = viewModel.categories
        let moved = reordered.remove(at: sourceIndexPath.row)
        reordered.insert(moved, at: destinationIndexPath.row)
        Task {
            await viewModel.reorderCategories(reordered)
        }
    }

    func tableView(
        _ tableView: UITableView,
        targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath
    ) -> IndexPath {
        let dest = viewModel.categories[proposedDestinationIndexPath.row]
        if !dest.isDeletable {
            return sourceIndexPath
        }
        return proposedDestinationIndexPath
    }

    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
        viewModel.categories[indexPath.row].isDeletable ? .delete : .none
    }

    func tableView(
        _ tableView: UITableView,
        shouldIndentWhileEditingRowAt indexPath: IndexPath
    ) -> Bool {
        false
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else { return }
        didTapDelete(at: indexPath.row)
    }
}

// MARK: - Helper
private extension CategoryManageViewController {

    func setup() {
        setupNavigationBar()
        setupSubviews()
        setupBottomButtons()
        setupConstraints()
        setupCategoryTableView()
    }

    func setupNavigationBar() {
        navigationBar.onLeftAction = { [weak self] in
            self?.dismiss(animated: true)
        }
        navigationBar.onRightAction = { [weak self] in
            self?.toggleEditingMode()
        }
    }

    func setupSubviews() {
        scrollView.showsVerticalScrollIndicator = false

        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(scrollContentView)

        [categoryTableView, addButton, resetButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scrollContentView.addSubview($0)
        }

        [navigationBar, scrollView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    func setupBottomButtons() {
        var addConfig = UIButton.Configuration.plain()
        addConfig.title = "+ 카테고리 추가"
        addConfig.baseForegroundColor = .DesignSystem.accent
        addConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            return a
        }
        addButton.configuration = addConfig
        addButton.isHidden = true
        addButton.addAction(UIAction { [weak self] _ in
            self?.presentEditSheet(category: nil)
        }, for: .touchUpInside)

        var resetConfig = UIButton.Configuration.plain()
        resetConfig.title = "카테고리 초기화"
        resetConfig.baseForegroundColor = .systemRed
        resetConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            return a
        }
        resetButton.configuration = resetConfig
        resetButton.isHidden = true
        resetButton.addAction(UIAction { [weak self] _ in
            self?.didTapReset()
        }, for: .touchUpInside)
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
            tableHeightConstraint,

            addButton.topAnchor.constraint(equalTo: categoryTableView.bottomAnchor, constant: 4),
            addButton.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20),
            addButton.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -20),

            resetButton.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            resetButton.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20),
            resetButton.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -20),
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
        }
    }

    func toggleEditingMode() {
        isEditingMode.toggle()
        navigationBar.updateRightButton(title: isEditingMode ? "완료" : "편집")
        categoryTableView.setEditing(isEditingMode, animated: true)
        UIView.animate(withDuration: 0.2) {
            self.addButton.isHidden = !self.isEditingMode
            self.resetButton.isHidden = !self.isEditingMode
        }
    }

    func didTapDelete(at index: Int) {
        let category = viewModel.categories[index]
        let alert = UIAlertController(
            title: "\"\(category.name)\" 삭제",
            message: "이 카테고리 지출은 '기타'로 변경됩니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            Task {
                await self?.viewModel.deleteCategory(at: index)
            }
        })
        present(alert, animated: true)
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
