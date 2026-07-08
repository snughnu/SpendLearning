//
//  AIViewController.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import UIKit

final class AIViewController: UIViewController {

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let statusView = AIStatusView()
    private let categoryPredictionView = AICategoryPredictionView()
    private let aIInsightView = AIInsightView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .DesignSystem.background
        setup()
        configureMock()
    }
}

// MARK: - Helper
private extension AIViewController {

    func setup() {
        setupSubviews()
        setupConstraints()
        setupTitleLabel()
    }

    func setupTitleLabel() {
        titleLabel.text = "소비 예측"
        titleLabel.font = .systemFont(ofSize: 24, weight: .heavy)
        titleLabel.textColor = .DesignSystem.primary
    }

    func setupSubviews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        [titleLabel, statusView, categoryPredictionView, aIInsightView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            statusView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            statusView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            categoryPredictionView.topAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 16),
            categoryPredictionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryPredictionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            aIInsightView.topAnchor.constraint(equalTo: categoryPredictionView.bottomAnchor, constant: 16),
            aIInsightView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            aIInsightView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            aIInsightView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60),
        ])
    }

    func configureMock() {
        statusView.configure(modelId: "CAT13A", dataCount: 1204, accuracy: 82)
        statusView.onExtract = { print("모델 생성하기 탭") }
        statusView.onSwitch = { print("모델 교체하기 탭") }

        aIInsightView.configure(items: [
            AIInsightItem(type: .abnormal, description: "이번 주 카페 지출이 평소보다 2.1배 많아요"),
            AIInsightItem(type: .forecast, description: "매주 월요일 교통비가 나가는 패턴이에요"),
            AIInsightItem(type: .unrecorded, description: "지난주 이맘때 교통비가 있었는데 이번 주엔 없네요"),
        ])
    }
}
