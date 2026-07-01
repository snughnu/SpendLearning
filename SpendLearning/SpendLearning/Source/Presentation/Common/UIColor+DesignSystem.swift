//
//  UIColor+DesignSystem.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import UIKit

extension UIColor {
    enum DesignSystem {
        /// Primary - 딥 브라운 네이비
        static let primary = UIColor(red: 0.18, green: 0.14, blue: 0.10, alpha: 1.0)

        /// Background - 흰색 베이지
        static let background = UIColor(red: 0.98, green: 0.97, blue: 0.96, alpha: 1.0)

        /// Surface - 흰색 (카드 배경)
        static let surface = UIColor.white

        /// Secondary - 연한 베이지 (아이콘 배경)
        static let secondary = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)

        /// Accent - 포인트 컬러 (선택 상태, 토글)
        static let accent = UIColor(red: 0.55, green: 0.42, blue: 0.28, alpha: 1.0)

        /// Subtitle - 중간 회색
        static let subtitle = UIColor(red: 0.50, green: 0.48, blue: 0.46, alpha: 1.0)

        /// Separator - 연한 구분선
        static let separator = UIColor(red: 0.91, green: 0.90, blue: 0.88, alpha: 1.0)
    }
}

// MARK: - Preview

import SwiftUI

private struct ColorRow: View {
    let name: String
    let color: UIColor

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(color))
                .frame(width: 48, height: 48)
            Text(name)
                .font(.system(size: 14, weight: .medium))
        }
    }
}

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 12) {
            ColorRow(name: "primary", color: .DesignSystem.primary)
            ColorRow(name: "background", color: .DesignSystem.background)
            ColorRow(name: "surface", color: .DesignSystem.surface)
            ColorRow(name: "secondary", color: .DesignSystem.secondary)
            ColorRow(name: "accent", color: .DesignSystem.accent)
            ColorRow(name: "subtitle", color: .DesignSystem.subtitle)
            ColorRow(name: "separator", color: .DesignSystem.separator)
        }
        .padding(20)
    }
}
