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
    private let separator = UIView()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    func configure(category: Category) {
        iconView.update(emoji: category.emoji)
        titleLabel.text = category.displayName
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
}

// MARK: - Helper
private extension SettingsCategoryCell {

    func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .DesignSystem.primary

        separator.backgroundColor = .DesignSystem.separator

        [iconView, titleLabel, separator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }
}
