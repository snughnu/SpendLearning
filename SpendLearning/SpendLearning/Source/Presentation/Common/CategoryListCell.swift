//
//  CategoryListCell.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import UIKit

final class CategoryListCell: UICollectionViewCell {

    // MARK: - UI
    private let iconView = IconCircleView(symbolName: "ellipsis.circle", size: 46)
    private let titleLabel = UILabel()
    private let separator = UIView()

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
        iconView.update(symbolName: category.symbolName)
        titleLabel.text = category.displayName
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
}

// MARK: - Helper
private extension CategoryListCell {

    func setup() {
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
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

            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }
}
