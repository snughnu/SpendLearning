//
//  ExpenseInputViewController.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import UIKit
import Combine

final class ExpenseInputViewController: UIViewController {

    // MARK: - UI
    private let navigationBar = CustomNavigationBar(
        title: "지출 확인",
        leftButtonTitle: "뒤로",
        rightButtonTitle: "저장"
    )
    private let cardView = UIView()

    private let categoryRow = UIView()
    private let categoryEmojiLabel = UILabel()
    private let categoryNameLabel = UILabel()
    private let categoryChevronImageView = UIImageView()
    private let categorySeparator = UIView()

    private let amountFieldLabel = UILabel()
    private let amountTextField = UITextField()
    private let amountSeparator = UIView()

    private let memoFieldLabel = UILabel()
    private let memoTextField = UITextField()

    // MARK: - Properties
    private let viewModel: NewExpenseViewModel
    private var cancellables = Set<AnyCancellable>()

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
        bindSelectedCategory()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        amountTextField.becomeFirstResponder()
    }
}

// MARK: - Actions
private extension ExpenseInputViewController {

    @objc func didTapSave() {
        Task {
            await viewModel.didSaveExpense()
            dismiss(animated: true)
        }
    }

    @objc func didTapBack() {
        dismiss(animated: true)
    }

    @objc func didTapCategoryRow() {
        let categorySelectVC = CategorySelectViewController(viewModel: viewModel)
        categorySelectVC.modalPresentationStyle = .fullScreen
        categorySelectVC.onCategorySelected = { [weak self, weak categorySelectVC] in
            categorySelectVC?.dismiss(animated: true)
            self?.updateCategoryDisplay()
        }
        present(categorySelectVC, animated: true)
    }

    @objc func amountDidChange() {
        let digitsOnly = (amountTextField.text ?? "").filter { $0.isNumber }
        let amount = Int(digitsOnly) ?? 0
        viewModel.didInputAmount(amount)
        amountTextField.text = amount == 0 ? "" : "\(amount.formatted())원"
    }
}

// MARK: - UITextFieldDelegate
extension ExpenseInputViewController: UITextFieldDelegate {

    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard textField == memoTextField else { return }
        viewModel.didInputMemo(textField.text ?? "")
    }
}

// MARK: - Helper
private extension ExpenseInputViewController {

    func setup() {
        setupNavigationBar()
        setupCardView()
        setupCategoryRow()
        setupAmountField()
        setupMemoField()
        setupConstraints()
        updateCategoryDisplay()
    }

    func setupNavigationBar() {
        navigationBar.onLeftAction = { [weak self] in
            self?.didTapBack()
        }
        navigationBar.onRightAction = { [weak self] in
            self?.didTapSave()
        }
    }

    func setupCardView() {
        cardView.backgroundColor = .DesignSystem.surface
        cardView.layer.cornerRadius = 16

        [navigationBar, cardView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    func setupCategoryRow() {
        categoryEmojiLabel.font = .systemFont(ofSize: 20)

        categoryNameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        categoryNameLabel.textColor = .DesignSystem.primary

        categoryChevronImageView.image = UIImage(systemName: "chevron.right")
        categoryChevronImageView.tintColor = .DesignSystem.subtitle
        categoryChevronImageView.contentMode = .scaleAspectFit

        categoryRow.isUserInteractionEnabled = true
        categoryRow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCategoryRow)))

        categorySeparator.backgroundColor = .DesignSystem.separator

        [categoryEmojiLabel, categoryNameLabel, categoryChevronImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            categoryRow.addSubview($0)
        }
        [categoryRow, categorySeparator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
        }
    }

    func setupAmountField() {
        amountFieldLabel.text = "금액"
        amountFieldLabel.font = .systemFont(ofSize: 13, weight: .regular)
        amountFieldLabel.textColor = .DesignSystem.subtitle

        amountTextField.text = viewModel.initialAmount == 0 ? "" : "\(viewModel.initialAmount.formatted())원"
        amountTextField.placeholder = "0"
        amountTextField.font = .systemFont(ofSize: 20, weight: .semibold)
        amountTextField.textColor = .DesignSystem.primary
        amountTextField.keyboardType = .numberPad
        amountTextField.addTarget(self, action: #selector(amountDidChange), for: .editingChanged)

        amountSeparator.backgroundColor = .DesignSystem.separator

        [amountFieldLabel, amountTextField, amountSeparator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
        }
    }

    func setupMemoField() {
        memoFieldLabel.text = "메모"
        memoFieldLabel.font = .systemFont(ofSize: 13, weight: .regular)
        memoFieldLabel.textColor = .DesignSystem.subtitle

        memoTextField.text = viewModel.initialMemo
        memoTextField.placeholder = "메모를 남겨보세요"
        memoTextField.font = .systemFont(ofSize: 16)
        memoTextField.autocapitalizationType = .none
        memoTextField.autocorrectionType = .no
        memoTextField.delegate = self

        [memoFieldLabel, memoTextField].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
        }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            cardView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 24),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            categoryRow.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            categoryRow.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            categoryRow.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            categoryRow.heightAnchor.constraint(equalToConstant: 28),

            categoryEmojiLabel.leadingAnchor.constraint(equalTo: categoryRow.leadingAnchor),
            categoryEmojiLabel.centerYAnchor.constraint(equalTo: categoryRow.centerYAnchor),

            categoryNameLabel.leadingAnchor.constraint(equalTo: categoryEmojiLabel.trailingAnchor, constant: 8),
            categoryNameLabel.centerYAnchor.constraint(equalTo: categoryRow.centerYAnchor),

            categoryChevronImageView.trailingAnchor.constraint(equalTo: categoryRow.trailingAnchor),
            categoryChevronImageView.centerYAnchor.constraint(equalTo: categoryRow.centerYAnchor),
            categoryChevronImageView.widthAnchor.constraint(equalToConstant: 14),
            categoryChevronImageView.heightAnchor.constraint(equalToConstant: 20),

            categorySeparator.topAnchor.constraint(equalTo: categoryRow.bottomAnchor, constant: 16),
            categorySeparator.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            categorySeparator.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            categorySeparator.heightAnchor.constraint(equalToConstant: 1),

            amountFieldLabel.topAnchor.constraint(equalTo: categorySeparator.bottomAnchor, constant: 16),
            amountFieldLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),

            amountTextField.topAnchor.constraint(equalTo: amountFieldLabel.bottomAnchor, constant: 4),
            amountTextField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            amountTextField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            amountSeparator.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 16),
            amountSeparator.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            amountSeparator.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            amountSeparator.heightAnchor.constraint(equalToConstant: 1),

            memoFieldLabel.topAnchor.constraint(equalTo: amountSeparator.bottomAnchor, constant: 16),
            memoFieldLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),

            memoTextField.topAnchor.constraint(equalTo: memoFieldLabel.bottomAnchor, constant: 4),
            memoTextField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            memoTextField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            memoTextField.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
        ])
    }

    func bindSelectedCategory() {
        viewModel.$selectedCategory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateCategoryDisplay()
            }
            .store(in: &cancellables)
    }

    func updateCategoryDisplay() {
        let category = viewModel.selectedCategory
        categoryEmojiLabel.text = category?.emoji ?? "📦"
        categoryNameLabel.text = category?.displayName ?? "기타"
    }
}
