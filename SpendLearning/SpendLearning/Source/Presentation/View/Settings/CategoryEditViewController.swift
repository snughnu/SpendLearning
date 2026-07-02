//
//  CategoryEditViewController.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import UIKit

private final class EmojiTextField: UITextField {
    override var textInputContextIdentifier: String? { "" }
    override var textInputMode: UITextInputMode? {
        UITextInputMode.activeInputModes.first { $0.primaryLanguage == "emoji" }
    }
}

final class CategoryEditViewController: UIViewController {

    // MARK: - UI
    private let titleLabel = UILabel()
    private let emojiField = EmojiTextField()
    private let emojiGuideLabel = UILabel()
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
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        setup()
        prefill()
        updateSaveButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emojiField.becomeFirstResponder()
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
        [titleLabel, emojiField, emojiGuideLabel, nameField, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    func setupLabels() {
        titleLabel.text = category == nil ? "카테고리 추가" : "카테고리 편집"
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .DesignSystem.primary
        titleLabel.textAlignment = .center

        emojiGuideLabel.text = "이모지 1개를 입력해주세요"
        emojiGuideLabel.font = .systemFont(ofSize: 12, weight: .regular)
        emojiGuideLabel.textColor = .DesignSystem.subtitle
        emojiGuideLabel.textAlignment = .center
    }

    func setupFields() {
        emojiField.font = .systemFont(ofSize: 36)
        emojiField.textAlignment = .center
        emojiField.backgroundColor = .DesignSystem.surface
        emojiField.layer.cornerRadius = 12
        emojiField.autocorrectionType = .no
        emojiField.addTarget(self, action: #selector(emojiFieldDidChange), for: .editingChanged)

        nameField.placeholder = "카테고리 이름"
        nameField.font = .systemFont(ofSize: 16, weight: .semibold)
        nameField.textColor = .DesignSystem.primary
        nameField.backgroundColor = .DesignSystem.surface
        nameField.layer.cornerRadius = 12
        nameField.autocorrectionType = .no
        nameField.autocapitalizationType = .none
        nameField.addTarget(self, action: #selector(nameFieldDidChange), for: .editingChanged)

        let namePadding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        nameField.leftView = namePadding
        nameField.leftViewMode = .always
    }

    func setupSaveButton() {
        saveButton.backgroundColor = .DesignSystem.primary
        saveButton.setTitle("저장", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitleColor(.white.withAlphaComponent(0.4), for: .disabled)
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

            emojiGuideLabel.topAnchor.constraint(equalTo: emojiField.bottomAnchor, constant: 8),
            emojiGuideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nameField.topAnchor.constraint(equalTo: emojiGuideLabel.bottomAnchor, constant: 20),
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

    func isValidEmoji(_ text: String) -> Bool {
        guard text.count == 1 else { return false }
        let char = text.unicodeScalars.first!
        return char.properties.isEmoji && char.properties.isEmojiPresentation
    }

    func updateSaveButton() {
        let emoji = emojiField.text ?? ""
        let name = nameField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let valid = isValidEmoji(emoji) && !name.isEmpty
        saveButton.isEnabled = valid
        saveButton.alpha = valid ? 1.0 : 0.4
    }

    @objc func emojiFieldDidChange() {
        let text = emojiField.text ?? ""
        if text.count > 1 {
            emojiField.text = String(text.prefix(1))
        }
        let emoji = emojiField.text ?? ""
        if !emoji.isEmpty && !isValidEmoji(emoji) {
            emojiGuideLabel.text = "이모지만 입력 가능해요"
            emojiGuideLabel.textColor = .systemRed
            emojiField.text = ""
        } else {
            emojiGuideLabel.text = "이모지 1개를 입력해주세요"
            emojiGuideLabel.textColor = .DesignSystem.subtitle
        }
        updateSaveButton()
    }

    @objc func nameFieldDidChange() {
        updateSaveButton()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func didTapSave() {
        let emoji = emojiField.text ?? ""
        let name = nameField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard isValidEmoji(emoji), !name.isEmpty else { return }
        onSave(name, emoji)
        dismiss(animated: true)
    }
}
