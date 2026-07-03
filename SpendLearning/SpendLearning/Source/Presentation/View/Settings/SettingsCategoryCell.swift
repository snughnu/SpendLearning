//
//  SettingsCategoryCell.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import UIKit

final class SettingsCategoryCell: UITableViewCell {

    static let reuseIdentifier = "SettingsCategoryCell"

    // MARK: - UI
    private let iconView = EmojiCircleView(emoji: "📦", size: 46)
    private let titleLabel = UILabel()
    private let editButton = UIButton()
    private let separator = UIView()

    // MARK: - Action
    var onEdit: (() -> Void)?

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    func configure(category: Category, isEditing: Bool) {
        iconView.update(emoji: category.emoji)
        titleLabel.text = category.displayName
        editButton.isHidden = !isEditing || !category.isDeletable
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        editButton.isHidden = true
        onEdit = nil
    }
}

// MARK: - Helper
private extension SettingsCategoryCell {

    func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .DesignSystem.primary

        editButton.setImage(UIImage(systemName: "pencil.line"), for: .normal)
        editButton.tintColor = .DesignSystem.subtitle
        editButton.isHidden = true
        editButton.addAction(UIAction { [weak self] _ in
            self?.onEdit?()
        }, for: .touchUpInside)

        separator.backgroundColor = .DesignSystem.separator

        [iconView, titleLabel, editButton, separator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            editButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 24),
            editButton.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -8),

            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }
}
