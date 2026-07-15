//
//  UIColor+DesignSystem.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import UIKit

extension UIColor {
    enum DesignSystem {
        /// Primary - 딥 올리브 다크
        static let primary = UIColor(red: 0.10, green: 0.12, blue: 0.08, alpha: 1.0) // #1A1F14

        /// Background - 크림 베이지 (올리브 톤)
        static let background = UIColor(red: 0.95, green: 0.95, blue: 0.92, alpha: 1.0) // #F2F2EB

        /// Surface - 연한 크림 화이트
        static let surface = UIColor(red: 0.98, green: 0.98, blue: 0.96, alpha: 1.0) // #FAFAF5

        /// Secondary - 연한 올리브 베이지 (아이콘 배경)
        static let secondary = UIColor(red: 0.85, green: 0.87, blue: 0.82, alpha: 1.0) // #D9DED1

        /// Accent - 국방색 포인트
        static let accent = UIColor(red: 0.325, green: 0.388, blue: 0.286, alpha: 1.0) // #536349

        /// Subtitle - 올리브 그레이
        static let subtitle = UIColor(red: 0.45, green: 0.48, blue: 0.42, alpha: 1.0) // #737A6B

        /// Separator - 연한 올리브 구분선
        static let separator = UIColor(red: 0.87, green: 0.88, blue: 0.85, alpha: 1.0) // #DEE1D9

        /// Chart Predicted - 버건디 브라운
        static let chartPredicted = UIColor(red: 0.478, green: 0.247, blue: 0.247, alpha: 1.0) // #7A3F3F
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
            ColorRow(name: "chartPredicted", color: .DesignSystem.chartPredicted)
        }
        .padding(20)
    }
}
