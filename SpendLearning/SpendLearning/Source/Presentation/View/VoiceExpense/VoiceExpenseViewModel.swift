//
//  VoiceExpenseViewModel.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/16/26.
//

import AVFoundation
import Foundation
import Speech

@Observable
@MainActor
final class VoiceExpenseViewModel {

    enum State {
        case idle
        case recording(transcript: String)
        case parsed(memo: String, amount: Int, category: Category)
        case error(String)
    }

    // MARK: - Output
    private(set) var state: State = .idle

    // MARK: - Private
    private let categoryUseCase: CategoryUseCaseProtocol
    private let categoryPredictor: CategoryPredictor
    private let parser = VoiceExpenseParser()

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    static let detailGuideText = """
    예시: 커피 4,500원

    순서를 지키지 않으면 인식이 어려워요
    금액 뒤에는 "원"을 꼭 붙여주세요
    
    신규 카테고리는 쓸수록 정확해져요
    """

    // MARK: - Init
    init(categoryUseCase: CategoryUseCaseProtocol, categoryPredictor: CategoryPredictor) {
        self.categoryUseCase = categoryUseCase
        self.categoryPredictor = categoryPredictor
    }

    // MARK: - Input

    func startRecording() async {
        guard hasPermissions() else {
            await requestPermissionsOnly()
            return
        }

        state = .recording(transcript: "")

        do {
            try beginRecognition()
        } catch {
            state = .error("녹음을 시작하지 못했어요")
        }
    }

    func stopRecording() async {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()

        guard case .recording(let transcript) = state else { return }
        await finishParsing(transcript: transcript)
    }

    func reset() {
        state = .idle
    }

    // MARK: - Private

    private func hasPermissions() -> Bool {
        let micStatus = AVAudioApplication.shared.recordPermission
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        return micStatus == .granted && speechStatus == .authorized
    }

    private func requestPermissionsOnly() async {
        let micGranted = await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        guard micGranted else {
            state = .error("마이크 접근 권한이 필요해요. 설정에서 허용해주세요")
            return
        }

        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        if speechStatus != .authorized {
            state = .error("음성 인식 권한이 필요해요. 설정에서 허용해주세요")
        }
        // 권한을 받았어도 여기서는 녹음을 시작하지 않는다 — 사용자가 다시 눌러야 시작됨
    }

    private func requestPermissions() async -> Bool {
        let micGranted = await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        guard micGranted else { return false }

        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        return speechStatus == .authorized
    }

    private func beginRecognition() throws {
        recognitionTask?.cancel()
        recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if speechRecognizer?.supportsOnDeviceRecognition == true {
            request.requiresOnDeviceRecognition = true
        }
        self.recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak request] buffer, _ in
            request?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            Task { @MainActor in
                if let result {
                    let text = result.bestTranscription.formattedString
                    if case .recording = self.state {
                        self.state = .recording(transcript: text)
                    }
                }
                if error != nil {
                    self.recognitionTask = nil
                }
            }
        }
    }

    private func finishParsing(transcript: String) async {
        let trimmed = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            state = .error("못 알아들었어요, 다시 말씀해주세요")
            return
        }

        switch parser.parse(trimmed) {
        case .success(let parsed):
            let prediction = categoryPredictor.predict(memo: parsed.memo)
            let categories = (try? await categoryUseCase.fetchCategories()) ?? []
            let matchedCategory = categories.first { $0.name == prediction.category }
                ?? categories.first { !$0.isDeletable }

            guard let category = matchedCategory else {
                state = .error("카테고리를 불러오지 못했어요")
                return
            }
            state = .parsed(memo: parsed.memo, amount: parsed.amount, category: category)

        case .failure:
            state = .error(Self.detailGuideText)
        }
    }
}
