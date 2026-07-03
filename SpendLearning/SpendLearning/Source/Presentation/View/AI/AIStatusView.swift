//
//  AIStatusView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/3/26.
//

import UIKit

final class AIStatusView: UIView {

    // MARK: - UI
    private let robotImageView = UIImageView()
    private let modelIdLabel = UILabel()
    private let dataCountLabel = UILabel()
    private let accuracyBar = UIProgressView(progressViewStyle: .default)
    private let extractButton = UIButton()
    private let switchButton = UIButton()

    // MARK: - Action
    var onExtract: (() -> Void)?
    var onSwitch: (() -> Void)?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    func configure(modelId: String, dataCount: Int, accuracy: Float) {
        modelIdLabel.text = "\(modelId) 예측 모델 (\(Int(accuracy))%)"
        dataCountLabel.text = "학습에 사용된 데이터: \(dataCount)개"
        accuracyBar.setProgress(accuracy / 100, animated: false)
    }
}

// MARK: - Helper
private extension AIStatusView {

    func setup() {
        backgroundColor = .DesignSystem.surface
        layer.cornerRadius = 20

        setupRobotImageView()
        setupLabels()
        setupAccuracyBar()
        setupButtons()
        setupSubviews()
        setupConstraints()
    }

    func setupRobotImageView() {
        robotImageView.image = UIImage(systemName: "cpu")
        robotImageView.contentMode = .scaleAspectFit
        robotImageView.tintColor = .DesignSystem.primary
    }

    func setupLabels() {
        modelIdLabel.font = .systemFont(ofSize: 16, weight: .bold)
        modelIdLabel.textColor = .DesignSystem.primary

        dataCountLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        dataCountLabel.textColor = .DesignSystem.subtitle
    }

    func setupAccuracyBar() {
        accuracyBar.progressTintColor = .DesignSystem.accent
        accuracyBar.trackTintColor = .DesignSystem.separator
        accuracyBar.layer.cornerRadius = 8
        accuracyBar.clipsToBounds = true
    }

    func setupButtons() {
        var extractConfig = UIButton.Configuration.filled()
        extractConfig.title = "모델 생성하기"
        extractConfig.baseBackgroundColor = .DesignSystem.primary
        extractConfig.baseForegroundColor = .white
        extractConfig.cornerStyle = .fixed
        extractConfig.background.cornerRadius = 14
        extractConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            return a
        }
        extractButton.configuration = extractConfig
        extractButton.addAction(UIAction { [weak self] _ in
            self?.onExtract?()
        }, for: .touchUpInside)

        var switchConfig = UIButton.Configuration.bordered()
        switchConfig.title = "모델 교체하기"
        switchConfig.baseBackgroundColor = .DesignSystem.accent
        switchConfig.baseForegroundColor = .white
        switchConfig.cornerStyle = .fixed
        switchConfig.background.cornerRadius = 14
        switchConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            return a
        }
        switchButton.configuration = switchConfig
        switchButton.addAction(UIAction { [weak self] _ in
            self?.onSwitch?()
        }, for: .touchUpInside)
    }

    func setupSubviews() {
        [robotImageView, modelIdLabel, dataCountLabel,
         accuracyBar, extractButton, switchButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            robotImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            robotImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            robotImageView.widthAnchor.constraint(equalToConstant: 64),
            robotImageView.heightAnchor.constraint(equalToConstant: 64),

            modelIdLabel.topAnchor.constraint(equalTo: robotImageView.topAnchor),
            modelIdLabel.leadingAnchor.constraint(equalTo: robotImageView.trailingAnchor, constant: 12),
            modelIdLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            dataCountLabel.topAnchor.constraint(equalTo: modelIdLabel.bottomAnchor, constant: 4),
            dataCountLabel.leadingAnchor.constraint(equalTo: modelIdLabel.leadingAnchor),
            dataCountLabel.trailingAnchor.constraint(equalTo: modelIdLabel.trailingAnchor),

            accuracyBar.topAnchor.constraint(equalTo: dataCountLabel.bottomAnchor, constant: 4),
            accuracyBar.leadingAnchor.constraint(equalTo: modelIdLabel.leadingAnchor),
            accuracyBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            accuracyBar.heightAnchor.constraint(equalToConstant: 16),

            extractButton.topAnchor.constraint(equalTo: robotImageView.bottomAnchor, constant: 20),
            extractButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            extractButton.heightAnchor.constraint(equalToConstant: 44),

            switchButton.topAnchor.constraint(equalTo: extractButton.topAnchor),
            switchButton.leadingAnchor.constraint(equalTo: extractButton.trailingAnchor, constant: 12),
            switchButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            switchButton.heightAnchor.constraint(equalToConstant: 44),
            switchButton.widthAnchor.constraint(equalTo: extractButton.widthAnchor),

            bottomAnchor.constraint(equalTo: extractButton.bottomAnchor, constant: 20),
        ])
    }
}
