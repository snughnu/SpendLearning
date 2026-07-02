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
    private lazy var navigationBar = CustomNavigationBar(
        title: viewModel.selectedCategory?.displayName ?? "",
        leftButtonTitle: "뒤로",
        rightButtonTitle: "저장"
    )
    private let amountLabel = UILabel()
    private let memoTextField = UITextField()
    private let amountTextField: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .numberPad
        tf.isHidden = true
        return tf
    }()

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        amountTextField.becomeFirstResponder()
    }
}

// MARK: - Actions
private extension ExpenseInputViewController {

    @objc func didTapSave() {
        Task {
            await viewModel.didSaveExpense()
            presentingViewController?.presentingViewController?.dismiss(animated: true)
        }
    }

    @objc func didTapBack() {
        dismiss(animated: true)
    }

    @objc func didTapAmountLabel() {
        amountTextField.becomeFirstResponder()
    }

    @objc func amountDidChange() {
        let amount = Int(amountTextField.text ?? "") ?? 0
        viewModel.didInputAmount(amount)
        amountLabel.text = amount == 0 ? "0원" : "\(amount.formatted())원"
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
        setupSubviews()
        setupConstraints()
    }

    func setupNavigationBar() {
        navigationBar.onLeftAction = { [weak self] in
            self?.didTapBack()
        }
        navigationBar.onRightAction = { [weak self] in
            self?.didTapSave()
        }
    }

    func setupSubviews() {
        let initialAmount = viewModel.initialAmount
        amountLabel.text = initialAmount == 0 ? "0원" : "\(initialAmount.formatted())원"
        amountLabel.font = .systemFont(ofSize: 40, weight: .bold)
        amountLabel.textColor = .DesignSystem.primary
        amountLabel.textAlignment = .center
        amountLabel.isUserInteractionEnabled = true
        amountLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapAmountLabel))
        )

        memoTextField.placeholder = "메모를 남겨보세요"
        memoTextField.text = viewModel.initialMemo
        memoTextField.font = .systemFont(ofSize: 15)
        memoTextField.backgroundColor = .white
        memoTextField.layer.cornerRadius = 12
        memoTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        memoTextField.leftViewMode = .always
        memoTextField.delegate = self

        amountTextField.text = initialAmount == 0 ? "" : "\(initialAmount)"
        amountTextField.addTarget(self, action: #selector(amountDidChange), for: .editingChanged)

        [navigationBar, amountLabel, memoTextField, amountTextField].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            amountLabel.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 40),
            amountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            amountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            memoTextField.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 24),
            memoTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            memoTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            memoTextField.heightAnchor.constraint(equalToConstant: 48),
        ])
    }
}
