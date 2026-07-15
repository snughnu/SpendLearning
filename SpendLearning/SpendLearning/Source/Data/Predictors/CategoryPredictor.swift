//
//  CategoryPredictor.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/16/26.
//

import CoreML
import Foundation

final class CategoryPredictor {

    // MARK: - Constants

    private static let chosung = Array("ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ").map(String.init)
    private static let jungsung = Array("ㅏㅐㅑㅒㅓㅔㅕㅖㅗㅘㅙㅚㅛㅜㅝㅞㅟㅠㅡㅢㅣ").map(String.init)
    private static let jongsung = [""] + Array("ㄱㄲㄳㄴㄵㄶㄷㄹㄺㄻㄼㄽㄾㄿㅀㅁㅂㅄㅅㅆㅇㅈㅊㅋㅌㅍㅎ").map(String.init)

    private static let fallbackCategory = "기타"

    // MARK: - Private

    private let vocabulary: [String]
    private var modelURL: URL?
    private var model: MLModel?

    // MARK: - Init

    init() {
        self.vocabulary = Self.loadVocabulary()
        prepareWritableModel()
    }

    // MARK: - Predict

    /// memo로부터 카테고리를 예측한다. 실패해도 항상 폴백 카테고리를 반환한다.
    func predict(memo: String) -> (category: String, confidence: Double) {
        guard let model, let vector = try? Self.vectorize(memo, vocabulary: vocabulary) else {
            return (Self.fallbackCategory, 0)
        }
        do {
            let provider = try MLDictionaryFeatureProvider(dictionary: ["input": vector])
            let output = try model.prediction(from: provider)
            guard let label = output.featureValue(for: "label")?.stringValue else {
                return (Self.fallbackCategory, 0)
            }
            let confidence = output.featureValue(for: "labelProbs")?.dictionaryValue[label]?.doubleValue ?? 0
            return (label, confidence)
        } catch {
            return (Self.fallbackCategory, 0)
        }
    }

    // MARK: - Update

    /// 사용자가 확정한 (memo, category) 쌍을 모델에 즉시 반영해 온디바이스로 학습한다.
    func update(memo: String, confirmedCategory: String) async throws {
        guard let modelURL else { return }
        let vector = try Self.vectorize(memo, vocabulary: vocabulary)
        let row = try MLDictionaryFeatureProvider(dictionary: ["input": vector, "label": confirmedCategory])
        let trainingData = MLArrayBatchProvider(array: [row])

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            do {
                let task = try MLUpdateTask(
                    forModelAt: modelURL,
                    trainingData: trainingData,
                    configuration: nil,
                    completionHandler: { [weak self] context in
                        do {
                            try context.model.write(to: modelURL)
                            self?.model = try MLModel(contentsOf: modelURL)
                            continuation.resume()
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                )
                task.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Reset

    /// 온디바이스 학습 데이터를 모두 지우고 번들에 포함된 원본 모델로 되돌린다.
    func resetToBundledModel() {
        guard let modelURL else { return }
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: modelURL)

        guard let bundledCompiledURL = Bundle.main.url(forResource: "CategoryClassifier", withExtension: "mlmodelc") else {
            return
        }
        try? fileManager.copyItem(at: bundledCompiledURL, to: modelURL)
        self.model = try? MLModel(contentsOf: modelURL)
    }
}

// MARK: - Setup

private extension CategoryPredictor {

    func prepareWritableModel() {
        let fileManager = FileManager.default
        guard let supportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return
        }
        try? fileManager.createDirectory(at: supportDir, withIntermediateDirectories: true)

        let writableURL = supportDir.appendingPathComponent("CategoryClassifier.mlmodelc")
        self.modelURL = writableURL

        guard let bundledCompiledURL = Bundle.main.url(forResource: "CategoryClassifier", withExtension: "mlmodelc") else {
            self.model = try? MLModel(contentsOf: writableURL)
            return
        }

        try? fileManager.removeItem(at: writableURL)
        try? fileManager.copyItem(at: bundledCompiledURL, to: writableURL)

        self.model = try? MLModel(contentsOf: writableURL)
    }

    static func loadVocabulary() -> [String] {
        guard let url = Bundle.main.url(forResource: "vocabulary", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let vocabulary = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return vocabulary
    }
}

// MARK: - Vectorization (train.py의 tokenize/vectorize와 반드시 동일해야 한다)

private extension CategoryPredictor {

    static func tokenize(_ text: String) -> [String] {
        var tokens: [String] = []
        for scalar in text.unicodeScalars {
            let code = Int(scalar.value)
            if code >= 0xAC00 && code <= 0xD7A3 {
                let offset = code - 0xAC00
                let choIndex = offset / (21 * 28)
                let jungIndex = (offset % (21 * 28)) / 28
                let jongIndex = offset % 28
                tokens.append(chosung[choIndex])
                tokens.append(jungsung[jungIndex])
                if jongIndex != 0 {
                    tokens.append("_" + jongsung[jongIndex])
                }
            } else {
                tokens.append(String(scalar))
            }
        }
        return tokens
    }

    static func vectorize(_ text: String, vocabulary: [String]) throws -> MLMultiArray {
        var counts: [String: Int] = [:]
        for token in tokenize(text) {
            counts[token, default: 0] += 1
        }
        let array = try MLMultiArray(shape: [NSNumber(value: vocabulary.count)], dataType: .double)
        for (index, token) in vocabulary.enumerated() {
            array[index] = NSNumber(value: Double(counts[token] ?? 0))
        }
        return array
    }
}
