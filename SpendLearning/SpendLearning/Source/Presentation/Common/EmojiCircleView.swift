//
//  EmojiCircleView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import UIKit

final class EmojiCircleView: UIView {

    private let emojiLabel = UILabel()

    init(emoji: String, size: CGFloat) {
        super.init(frame: .zero)
        setup(emoji: emoji, size: size)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(emoji: String) {
        emojiLabel.text = emoji
    }
}

// MARK: - Helper
private extension EmojiCircleView {

    func setup(emoji: String, size: CGFloat) {
        backgroundColor = .DesignSystem.secondary
        layer.cornerRadius = size / 2

        emojiLabel.text = emoji
        emojiLabel.font = .systemFont(ofSize: size * 0.43)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size),
            emojiLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
