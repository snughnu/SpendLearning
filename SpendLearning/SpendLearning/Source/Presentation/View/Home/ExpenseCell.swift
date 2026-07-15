//
//  ExpenseCell.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import UIKit

final class ExpenseCell: UICollectionViewCell {

    private let iconView = EmojiCircleView(emoji: "📦", size: 38)
    private let categoryLabel = UILabel()
    private let memoLabel = UILabel()
    private let amountLabel = UILabel()
    private let separator = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        categoryLabel.text = nil
        memoLabel.text = nil
        amountLabel.text = nil
        memoLabel.isHidden = false
        separator.isHidden = false
    }

    func configure(category: Category, memo: String?, amount: Int) {
        iconView.update(emoji: category.emoji)
        categoryLabel.text = category.displayName
        memoLabel.text = memo ?? " "
        amountLabel.text = "\(amount.formatted())원"
    }
}

// MARK: - Helper
private extension ExpenseCell {

    func setup() {
        backgroundColor = .clear

        let textStack = UIStackView(arrangedSubviews: [categoryLabel, memoLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        separator.backgroundColor = .DesignSystem.separator

        [iconView, textStack, amountLabel, separator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        categoryLabel.font = .systemFont(ofSize: 14, weight: .bold)
        categoryLabel.textColor = .DesignSystem.primary

        memoLabel.font = .systemFont(ofSize: 12, weight: .regular)
        memoLabel.textColor = .DesignSystem.subtitle

        amountLabel.font = .systemFont(ofSize: 14.5, weight: .bold)
        amountLabel.textColor = .DesignSystem.primary

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            textStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            amountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: textStack.trailingAnchor, constant: 8),

            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
}
