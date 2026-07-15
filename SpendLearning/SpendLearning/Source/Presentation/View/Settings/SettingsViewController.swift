//
//  SettingsViewController.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import UIKit
import Combine

final class SettingsViewController: UIViewController {

    // MARK: - UI
    private let titleLabel = UILabel()
    private let categorySectionLabel = UILabel()
    private let categoryRowView = SettingsRowView()
    private let dataSectionLabel = UILabel()
    private let resetRowView = SettingsRowView()

    // MARK: - Properties
    private let viewModel: SettingsViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(
        categoryUseCase: CategoryUseCaseProtocol,
        expenseUseCase: ExpenseUseCaseProtocol,
        predictionUseCase: PredictionUseCaseProtocol,
        categoryPredictor: CategoryPredictor
    ) {
        self.viewModel = SettingsViewModel(
            categoryUseCase: categoryUseCase,
            expenseUseCase: expenseUseCase,
            predictionUseCase: predictionUseCase,
            categoryPredictor: categoryPredictor
        )
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
private extension SettingsViewController {

    func bind() {
        viewModel.$categories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] categories in
                self?.categoryRowView.configure(
                    iconName: "list.bullet",
                    title: "카테고리 관리",
                    subtitle: "\(categories.count)개 카테고리 사용 중"
                )
            }
            .store(in: &cancellables)
    }
}

// MARK: - Helper
private extension SettingsViewController {

    func setup() {
        setupSubviews()
        setupLabels()
        setupConstraints()
        setupCategoryRow()
        setupResetRow()
    }

    func setupSubviews() {
        [titleLabel, categorySectionLabel, categoryRowView, dataSectionLabel, resetRowView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    func setupLabels() {
        titleLabel.text = "설정"
        titleLabel.font = .systemFont(ofSize: 24, weight: .heavy)
        titleLabel.textColor = .DesignSystem.primary

        categorySectionLabel.text = "카테고리"
        categorySectionLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        categorySectionLabel.textColor = .DesignSystem.subtitle

        dataSectionLabel.text = "데이터"
        dataSectionLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        dataSectionLabel.textColor = .DesignSystem.subtitle
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            categorySectionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 28),
            categorySectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            categoryRowView.topAnchor.constraint(equalTo: categorySectionLabel.bottomAnchor, constant: 8),
            categoryRowView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryRowView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            categoryRowView.heightAnchor.constraint(equalToConstant: 72),

            dataSectionLabel.topAnchor.constraint(equalTo: categoryRowView.bottomAnchor, constant: 28),
            dataSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            resetRowView.topAnchor.constraint(equalTo: dataSectionLabel.bottomAnchor, constant: 8),
            resetRowView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resetRowView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resetRowView.heightAnchor.constraint(equalToConstant: 72),
        ])
    }

    func setupCategoryRow() {
        categoryRowView.onTap = { [weak self] in
            self?.pushCategoryManage()
        }
    }

    func setupResetRow() {
        resetRowView.configure(iconName: "trash", title: "전체 초기화", subtitle: "모든 소비 기록과 예측이 삭제돼요")
        resetRowView.onTap = { [weak self] in
            self?.showResetConfirmAlert()
        }
    }

    func loadCategories() {
        Task {
            await viewModel.loadCategories()
        }
    }

    func pushCategoryManage() {
        let manageVC = CategoryManageViewController(viewModel: viewModel)
        manageVC.modalPresentationStyle = .fullScreen
        present(manageVC, animated: true)
    }

    func showResetConfirmAlert() {
        let alert = UIAlertController(
            title: "전체 초기화",
            message: "모든 소비 기록, 카테고리 설정,\n예측이 초기화돼요.\n이 작업은 되돌릴 수 없어요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "초기화", style: .destructive) { [weak self] _ in
            self?.resetAllData()
        })
        present(alert, animated: true)
    }

    func resetAllData() {
        Task {
            await viewModel.resetAllData()
        }
    }
}
