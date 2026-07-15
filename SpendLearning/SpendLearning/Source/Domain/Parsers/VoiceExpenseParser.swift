//
//  VoiceExpenseParser.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/16/26.
//

import Foundation

struct VoiceExpenseParser {

    struct ParsedExpense {
        let memo: String
        let amount: Int
    }

    enum ParseError: Error {
        case amountNotFound
        case memoEmpty
    }

    /// "스타벅스 4500원" 같은 문장에서 메모와 금액을 분리한다.
    func parse(_ transcript: String) -> Result<ParsedExpense, ParseError> {
        let trimmed = transcript.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let range = trimmed.range(
            of: #"[0-9][0-9,]*\s*(원|₩)"#,
            options: .regularExpression
        ) else {
            return .failure(.amountNotFound)
        }

        let amountDigits = trimmed[range].filter { $0.isNumber }
        guard let amount = Int(amountDigits), amount > 0 else {
            return .failure(.amountNotFound)
        }

        let memo = trimmed[trimmed.startIndex..<range.lowerBound]
            .trimmingCharacters(in: .whitespaces)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-₩"))
            .trimmingCharacters(in: .whitespaces)
        guard !memo.isEmpty else {
            return .failure(.memoEmpty)
        }

        return .success(ParsedExpense(memo: memo, amount: amount))
    }
}
