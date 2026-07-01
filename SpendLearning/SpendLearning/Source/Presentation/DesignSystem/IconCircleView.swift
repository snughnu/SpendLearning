//
//  IconCircleView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import UIKit

final class IconCircleView: UIView {
    private let imageView = UIImageView()

    init(symbolName: String, size: CGFloat) {
        super.init(frame: .zero)
        setup(symbolName: symbolName, size: size)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setup(symbolName: String, size: CGFloat) {
        backgroundColor = .DesignSystem.secondary
        layer.cornerRadius = size / 2

        let iconSize = size * 0.43
        let config = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .medium)
        imageView.image = UIImage(systemName: symbolName, withConfiguration: config)
        imageView.tintColor = .DesignSystem.primary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: iconSize),
            imageView.heightAnchor.constraint(equalToConstant: iconSize),
        ])
    }
}
