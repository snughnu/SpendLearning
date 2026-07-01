//
//  CategoryCell.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import UIKit

final class CategoryCell: UICollectionViewCell {

    private let itemView: CategoryItemView

    override init(frame: CGRect) {
        self.itemView = CategoryItemView(symbolName: "ellipsis.circle", title: "")
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        itemView.setSelected(false)
    }

    func configure(category: Category, isSelected: Bool) {
        itemView.update(symbolName: category.symbolName, title: category.displayName)
        itemView.setSelected(isSelected)
    }
}

// MARK: - Helper
private extension CategoryCell {

    func setup() {
        itemView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(itemView)

        NSLayoutConstraint.activate([
            itemView.topAnchor.constraint(equalTo: contentView.topAnchor),
            itemView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            itemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            itemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
}
