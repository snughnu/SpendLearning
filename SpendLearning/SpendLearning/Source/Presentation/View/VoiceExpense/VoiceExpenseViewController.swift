//
//  VoiceExpenseViewController.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/16/26.
//

import UIKit

final class VoiceExpenseViewController: UIViewController {

    // MARK: - UI
    private let titleLabel = UILabel()

    private let transcriptCardView = UIView()
    private let fixedGuideLabel = UILabel()
    private let transcriptSeparator = UIView()
    private let contentLabel = UILabel()
    private let settingsButton = UIButton(type: .system)

    private let micCardView = UIView()
    private let micButton = UIButton()
    private let hintLabel = UILabel()

    // MARK: - Properties
    private let viewModel: VoiceExpenseViewModel
    private let expenseUseCase: ExpenseUseCaseProtocol
    private let categoryUseCase: CategoryUseCaseProtocol
    private let categoryPredictor: CategoryPredictor
    private var displayLink: CADisplayLink?

    // MARK: - Init
    init(
        viewModel: VoiceExpenseViewModel,
        expenseUseCase: ExpenseUseCaseProtocol,
        categoryUseCase: CategoryUseCaseProtocol,
        categoryPredictor: CategoryPredictor
    ) {
        self.viewModel = viewModel
        self.expenseUseCase = expenseUseCase
        self.categoryUseCase = categoryUseCase
        self.categoryPredictor = categoryPredictor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .DesignSystem.background
        setup()
        render()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startObservingState()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingState()
    }
}

// MARK: - State Observation
// @Observable은 SwiftUI 밖(UIKit)에서는 자동 구독이 없어, 짧은 주기로 폴링해 상태 변화를 감지
// 녹음 중 실시간 자막 갱신이 필요해 매 프레임 체크가 필요하므로 CADisplayLink를 사용
private extension VoiceExpenseViewController {

    func startObservingState() {
        displayLink?.invalidate()
        let link = CADisplayLink(target: self, selector: #selector(pollState))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func stopObservingState() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc func pollState() {
        render()
    }
}

// MARK: - Actions
private extension VoiceExpenseViewController {

    @objc func didTouchDown() {
        Task { await viewModel.startRecording() }
    }

    @objc func didTouchUp() {
        Task { await viewModel.stopRecording() }
    }

    @objc func didTapSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Render
private extension VoiceExpenseViewController {

    func render() {
        settingsButton.isHidden = true

        switch viewModel.state {
        case .idle:
            contentLabel.text = VoiceExpenseViewModel.detailGuideText
            contentLabel.font = .systemFont(ofSize: 14, weight: .regular)
            contentLabel.textColor = .DesignSystem.subtitle
            micButton.transform = .identity

        case .recording(let transcript):
            contentLabel.text = transcript.isEmpty ? "듣고 있어요..." : transcript
            contentLabel.font = .systemFont(ofSize: 20, weight: .medium)
            contentLabel.textColor = .DesignSystem.primary
            micButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)

        case .parsed(let memo, let amount, let category):
            micButton.transform = .identity
            presentConfirm(memo: memo, amount: amount, category: category)

        case .error(let message):
            contentLabel.text = message
            contentLabel.font = .systemFont(ofSize: 16, weight: .medium)
            contentLabel.textColor = .DesignSystem.primary
            micButton.transform = .identity

        case .permissionDenied(let message):
            contentLabel.text = message
            contentLabel.font = .systemFont(ofSize: 16, weight: .medium)
            contentLabel.textColor = .systemRed
            micButton.transform = .identity
            settingsButton.isHidden = false
        }
    }

    func presentConfirm(memo: String, amount: Int, category: Category) {
        viewModel.reset()
        let vm = NewExpenseViewModel(
            expenseUseCase: expenseUseCase,
            categoryUseCase: categoryUseCase,
            date: Date(),
            prefillAmount: amount,
            prefillMemo: memo,
            prefillCategory: category
        )
        Task {
            await vm.loadCategories()
            let inputVC = ExpenseInputViewController(viewModel: vm)
            inputVC.modalPresentationStyle = .fullScreen
            inputVC.onDidSave = { [weak self] in
                guard let self else { return }
                Task {
                    try? await self.categoryPredictor.update(
                        memo: vm.finalMemo,
                        confirmedCategory: vm.selectedCategory?.name ?? category.name
                    )
                }
            }
            present(inputVC, animated: true)
        }
    }
}

// MARK: - Helper
private extension VoiceExpenseViewController {

    func setup() {
        setupSubviews()
        setupConstraints()
    }

    func setupSubviews() {
        titleLabel.text = "음성으로 추가"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .DesignSystem.primary

        transcriptCardView.backgroundColor = .DesignSystem.surface
        transcriptCardView.layer.cornerRadius = 16

        fixedGuideLabel.text = "\"메모 금액\" 순서로 말해주세요"
        fixedGuideLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        fixedGuideLabel.textColor = .DesignSystem.primary
        fixedGuideLabel.textAlignment = .center

        transcriptSeparator.backgroundColor = .DesignSystem.separator

        contentLabel.text = VoiceExpenseViewModel.detailGuideText
        contentLabel.font = .systemFont(ofSize: 14, weight: .regular)
        contentLabel.textColor = .DesignSystem.subtitle
        contentLabel.textAlignment = .center
        contentLabel.numberOfLines = 0

        settingsButton.setTitle("설정으로 이동", for: .normal)
        settingsButton.setTitleColor(.DesignSystem.accent, for: .normal)
        settingsButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        settingsButton.addTarget(self, action: #selector(didTapSettings), for: .touchUpInside)
        settingsButton.isHidden = true

        micCardView.backgroundColor = .DesignSystem.surface
        micCardView.layer.cornerRadius = 16

        let micSymbolConfig = UIImage.SymbolConfiguration(pointSize: 72, weight: .regular)
        micButton.setImage(UIImage(systemName: "mic.circle.fill", withConfiguration: micSymbolConfig), for: .normal)
        micButton.tintColor = .DesignSystem.accent
        micButton.imageView?.contentMode = .scaleAspectFit
        micButton.addTarget(self, action: #selector(didTouchDown), for: .touchDown)
        micButton.addTarget(self, action: #selector(didTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        hintLabel.text = "눌러서 말하기"
        hintLabel.font = .systemFont(ofSize: 13, weight: .regular)
        hintLabel.textColor = .DesignSystem.subtitle
        hintLabel.textAlignment = .center

        [fixedGuideLabel, transcriptSeparator, contentLabel, settingsButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            transcriptCardView.addSubview($0)
        }
        [micButton, hintLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            micCardView.addSubview($0)
        }
        [titleLabel, transcriptCardView, micCardView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            transcriptCardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            transcriptCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            transcriptCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            transcriptCardView.bottomAnchor.constraint(equalTo: micCardView.topAnchor, constant: -24),

            fixedGuideLabel.topAnchor.constraint(equalTo: transcriptCardView.topAnchor, constant: 24),
            fixedGuideLabel.leadingAnchor.constraint(equalTo: transcriptCardView.leadingAnchor, constant: 20),
            fixedGuideLabel.trailingAnchor.constraint(equalTo: transcriptCardView.trailingAnchor, constant: -20),

            transcriptSeparator.topAnchor.constraint(equalTo: fixedGuideLabel.bottomAnchor, constant: 16),
            transcriptSeparator.leadingAnchor.constraint(equalTo: transcriptCardView.leadingAnchor, constant: 20),
            transcriptSeparator.trailingAnchor.constraint(equalTo: transcriptCardView.trailingAnchor, constant: -20),
            transcriptSeparator.heightAnchor.constraint(equalToConstant: 1),

            contentLabel.topAnchor.constraint(greaterThanOrEqualTo: transcriptSeparator.bottomAnchor, constant: 16),
            contentLabel.leadingAnchor.constraint(equalTo: transcriptCardView.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: transcriptCardView.trailingAnchor, constant: -20),
            contentLabel.centerYAnchor.constraint(
                equalTo: transcriptCardView.centerYAnchor, constant: 20
            ).with(priority: .defaultHigh),

            settingsButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 12),
            settingsButton.centerXAnchor.constraint(equalTo: transcriptCardView.centerXAnchor),
            settingsButton.bottomAnchor.constraint(lessThanOrEqualTo: transcriptCardView.bottomAnchor, constant: -24),

            micCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            micCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            micCardView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            micCardView.heightAnchor.constraint(equalToConstant: 200),

            micButton.widthAnchor.constraint(equalToConstant: 88),
            micButton.heightAnchor.constraint(equalToConstant: 88),
            micButton.centerXAnchor.constraint(equalTo: micCardView.centerXAnchor),
            micButton.topAnchor.constraint(equalTo: micCardView.topAnchor, constant: 32),

            hintLabel.topAnchor.constraint(equalTo: micButton.bottomAnchor, constant: 12),
            hintLabel.centerXAnchor.constraint(equalTo: micCardView.centerXAnchor),
        ])
    }
}

private extension NSLayoutConstraint {
    func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
