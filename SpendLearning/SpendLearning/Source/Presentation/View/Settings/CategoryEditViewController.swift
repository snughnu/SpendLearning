//
//  CategoryEditViewController.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import UIKit

final class CategoryEditViewController: UIViewController {

    // MARK: - UI
    private let titleLabel = UILabel()
    private let emojiField = UITextField()
    private let nameField = UITextField()
    private let saveButton = UIButton()

    // MARK: - Properties
    private let category: Category?
    private let onSave: (String, String) -> Void

    // MARK: - Init
    init(
        category: Category?,
        onSave: @escaping (String, String) -> Void
    ) {
        self.category = category
        self.onSave = onSave
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
        prefill()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nameField.becomeFirstResponder()
    }
}

// MARK: - Helper
private extension CategoryEditViewController {

    func setup() {
        setupSubviews()
        setupLabels()
        setupFields()
        setupSaveButton()
        setupConstraints()
    }

    func setupSubviews() {
        [titleLabel, emojiField, nameField, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    func setupLabels() {
        titleLabel.text = category == nil ? "카테고리 추가" : "카테고리 편집"
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .DesignSystem.primary
        titleLabel.textAlignment = .center
    }

    func setupFields() {
        emojiField.placeholder = "이모지"
        emojiField.font = .systemFont(ofSize: 32)
        emojiField.textAlignment = .center
        emojiField.backgroundColor = .DesignSystem.surface
        emojiField.layer.cornerRadius = 12
        emojiField.autocorrectionType = .no

        nameField.placeholder = "카테고리 이름"
        nameField.font = .systemFont(ofSize: 16, weight: .semibold)
        nameField.textColor = .DesignSystem.primary
        nameField.backgroundColor = .DesignSystem.surface
        nameField.layer.cornerRadius = 12
        nameField.autocorrectionType = .no
        nameField.autocapitalizationType = .none

        let namePadding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        nameField.leftView = namePadding
        nameField.leftViewMode = .always
    }

    func setupSaveButton() {
        saveButton.backgroundColor = .DesignSystem.primary
        saveButton.setTitle("저장", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        saveButton.layer.cornerRadius = 14
        saveButton.addAction(UIAction { [weak self] _ in
            self?.didTapSave()
        }, for: .touchUpInside)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            emojiField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            emojiField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emojiField.widthAnchor.constraint(equalToConstant: 72),
            emojiField.heightAnchor.constraint(equalToConstant: 72),

            nameField.topAnchor.constraint(equalTo: emojiField.bottomAnchor, constant: 30),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameField.heightAnchor.constraint(equalToConstant: 52),

            saveButton.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 100),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }

    func prefill() {
        guard let category else { return }
        emojiField.text = category.emoji
        nameField.text = category.name
    }

    func didTapSave() {
        let emoji = emojiField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let name = nameField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !name.isEmpty else { return }
        onSave(name, emoji.isEmpty ? "📦" : emoji)
        dismiss(animated: true)
    }
}
