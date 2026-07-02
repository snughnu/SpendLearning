//
//  SettingsCategoryCell.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import UIKit

final class SettingsCategoryCell: UICollectionViewCell {

    // MARK: - UI
    private let iconView = EmojiCircleView(emoji: "📦", size: 46)
    private let titleLabel = UILabel()
    private let deleteButton = UIButton()
    private let dragHandleImageView = UIImageView()
    private let separator = UIView()

    // MARK: - Action
    var onDelete: (() -> Void)?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    func configure(category: Category) {
        iconView.update(emoji: category.emoji)
        titleLabel.text = category.displayName
        deleteButton.isHidden = !category.isDeletable
        dragHandleImageView.isHidden = !category.isDeletable
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        onDelete = nil
        deleteButton.isHidden = false
    }
}

// MARK: - Helper
private extension SettingsCategoryCell {

    func setup() {
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .DesignSystem.primary

        let handleConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        dragHandleImageView.image = UIImage(systemName: "line.3.horizontal", withConfiguration: handleConfig)
        dragHandleImageView.tintColor = .DesignSystem.subtitle
        dragHandleImageView.contentMode = .scaleAspectFit

        var config = UIButton.Configuration.plain()
        config.image = UIImage(
            systemName: "trash",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        )
        config.baseForegroundColor = .DesignSystem.subtitle
        config.contentInsets = .zero
        deleteButton.configuration = config
        deleteButton.addAction(UIAction { [weak self] _ in
            self?.onDelete?()
        }, for: .touchUpInside)

        separator.backgroundColor = .DesignSystem.separator

        [iconView, titleLabel, dragHandleImageView, deleteButton, separator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            dragHandleImageView.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -12),
            dragHandleImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dragHandleImageView.widthAnchor.constraint(equalToConstant: 20),
            dragHandleImageView.heightAnchor.constraint(equalToConstant: 20),

            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 28),
            deleteButton.heightAnchor.constraint(equalToConstant: 28),

            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: deleteButton.leadingAnchor, constant: -8),

            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }
}
