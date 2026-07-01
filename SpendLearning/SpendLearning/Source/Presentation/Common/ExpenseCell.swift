//
//  ExpenseCell.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import UIKit

final class ExpenseCell: UITableViewCell {
    static let identifier = "ExpenseCell"

    private let iconView = IconCircleView(symbolName: "ellipsis", size: 38)
    private let categoryLabel = UILabel()
    private let memoLabel = UILabel()
    private let amountLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        categoryLabel.text = nil
        memoLabel.text = nil
        amountLabel.text = nil
        memoLabel.isHidden = false
    }

    func configure(symbolName: String, category: String, memo: String?, amount: Int) {
        iconView.update(symbolName: symbolName)
        categoryLabel.text = category
        memoLabel.text = memo
        memoLabel.isHidden = memo == nil
        amountLabel.text = "\(amount.formatted())원"
    }
}

// MARK: - Helper
private extension ExpenseCell {

    func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        let textStack = UIStackView(arrangedSubviews: [categoryLabel, memoLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        [iconView, textStack, amountLabel].forEach {
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
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            textStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            amountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: textStack.trailingAnchor, constant: 8),

            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 58),
        ])
    }
}
