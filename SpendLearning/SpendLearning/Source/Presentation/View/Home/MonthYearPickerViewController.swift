//
//  MonthYearPickerViewController.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import UIKit

final class MonthYearPickerViewController: UIViewController {

    var onConfirm: ((Int, Int, Date) -> Void)?

    private let picker = UIDatePicker()
    private let confirmButton = UIButton()

    init(year: Int, month: Int) {
        super.init(nibName: nil, bundle: nil)

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        picker.date = Calendar.current.date(from: components) ?? Date()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: - Actions
private extension MonthYearPickerViewController {

    @objc func didTapConfirm() {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: picker.date)
        let month = calendar.component(.month, from: picker.date)
        let selectedDay = calendar.startOfDay(for: picker.date)
        onConfirm?(year, month, selectedDay)
        dismiss(animated: true)
    }
}

// MARK: - Helper
private extension MonthYearPickerViewController {

    func setup() {
        view.backgroundColor = .DesignSystem.background
        setupSubviews()
        setupPicker()
        setupConfirmButton()
        setupConstraints()
    }

    func setupSubviews() {
        [picker, confirmButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    func setupPicker() {
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko_KR")
        picker.minimumDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1))
        picker.maximumDate = Calendar.current.date(from: DateComponents(year: 2099, month: 12))
    }

    func setupConfirmButton() {
        confirmButton.backgroundColor = .DesignSystem.primary
        confirmButton.setTitle("확인", for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        confirmButton.layer.cornerRadius = 14
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            picker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            confirmButton.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: 16),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 52),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
}
