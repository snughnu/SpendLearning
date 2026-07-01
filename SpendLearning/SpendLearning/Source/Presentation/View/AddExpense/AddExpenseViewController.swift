//
//  AddExpenseViewController.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import UIKit

final class AddExpenseViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .DesignSystem.background
        setupNavigationBar()
    }
}

// MARK: - Actions
private extension AddExpenseViewController {

    @objc func didTapCancel() {
        dismiss(animated: true)
    }
}

// MARK: - Helper
private extension AddExpenseViewController {

    func setupNavigationBar() {
        title = "지출 입력"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(didTapCancel)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "저장",
            style: .prominent,
            target: nil,
            action: nil
        )

        navigationController?.navigationBar.tintColor = .DesignSystem.accent
    }
}
