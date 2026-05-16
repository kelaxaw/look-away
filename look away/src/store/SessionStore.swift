//
//  SessionStore.swift
//  look away
//

import Foundation
import Observation

enum SessionPhase: Equatable {
    case idle
    case working
    case onBreak
}

@Observable
@MainActor
final class SessionStore {
    var workDurationMinutes: Int = 20
    var breakDurationSeconds: Int = 30

    var blinkReminderEnabled: Bool = true
    var blinkIntervalMinutes: Int = 1

    var moveReminderEnabled: Bool = true
    var moveIntervalMinutes: Int = 15

    private(set) var phase: SessionPhase = .idle
    private(set) var secondsRemaining: Int = 0
    private(set) var blinkReminderActive: Bool = false
    private(set) var moveReminderActive: Bool = false

    private var workDurationInSeconds: Int { max(1, workDurationMinutes) * 60 }
    private var breakDurationInSeconds: Int { max(1, breakDurationSeconds) }
    private var blinkIntervalInSeconds: TimeInterval { TimeInterval(max(1, blinkIntervalMinutes) * 60) }
    private var moveIntervalInSeconds: TimeInterval { TimeInterval(max(1, moveIntervalMinutes) * 60) }
    private let blinkReminderDuration: TimeInterval = 3.5
    private let moveReminderDuration: TimeInterval = 5.0

    private var timer: Timer?
    private var blinkTimer: Timer?
    private var blinkDismissTimer: Timer?
    private var moveTimer: Timer?
    private var moveDismissTimer: Timer?
    private let notifications = NotificationManager()

    var formattedTime: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var formattedMinutes: String {
        let minutes = Int(ceil(Double(max(0, secondsRemaining)) / 60.0))
        return "\(minutes)m"
    }

    func start() {
        guard phase == .idle else { return }
        Task { await notifications.requestAuthorizationIfNeeded() }
        beginWorking()
    }

    func endSession() {
        stopTimer()
        stopBlinkTimers()
        stopMoveTimers()
        blinkReminderActive = false
        moveReminderActive = false
        phase = .idle
        secondsRemaining = 0
    }

    func skipBreak() {
        guard phase == .onBreak else { return }
        beginWorking()
    }

    func extendWork(byMinutes minutes: Int) {
        guard phase == .working, minutes > 0 else { return }
        secondsRemaining += minutes * 60
    }

    var shouldShowPreBreakToolbar: Bool {
        phase == .working && secondsRemaining > 0 && secondsRemaining <= 30
    }

    private func beginWorking() {
        phase = .working
        secondsRemaining = workDurationInSeconds
        startTimer()
        startBlinkTimerIfNeeded()
        startMoveTimerIfNeeded()
    }

    private func beginBreak() {
        phase = .onBreak
        secondsRemaining = breakDurationInSeconds
        stopBlinkTimers()
        stopMoveTimers()
        blinkReminderActive = false
        moveReminderActive = false
        notifications.notifyBreakStarted()
        startTimer()
    }

    func restartBlinkScheduling() {
        guard phase == .working else { return }
        stopBlinkTimers()
        blinkReminderActive = false
        startBlinkTimerIfNeeded()
    }

    func restartMoveScheduling() {
        guard phase == .working else { return }
        stopMoveTimers()
        moveReminderActive = false
        startMoveTimerIfNeeded()
    }

    private func startBlinkTimerIfNeeded() {
        guard blinkReminderEnabled else { return }
        blinkTimer = Timer.scheduledTimer(
            withTimeInterval: blinkIntervalInSeconds,
            repeats: true
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.fireBlinkReminder()
            }
        }
    }

    private func fireBlinkReminder() {
        guard phase == .working, blinkReminderEnabled else { return }
        blinkReminderActive = true
        blinkDismissTimer?.invalidate()
        blinkDismissTimer = Timer.scheduledTimer(
            withTimeInterval: blinkReminderDuration,
            repeats: false
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.blinkReminderActive = false
            }
        }
    }

    private func stopBlinkTimers() {
        blinkTimer?.invalidate()
        blinkTimer = nil
        blinkDismissTimer?.invalidate()
        blinkDismissTimer = nil
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.tick()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard secondsRemaining > 0 else {
            advancePhase()
            return
        }
        secondsRemaining -= 1
        if secondsRemaining == 0 {
            advancePhase()
        }
    }

    private func advancePhase() {
        switch phase {
        case .working:
            beginBreak()
        case .onBreak:
            beginWorking()
        case .idle:
            stopTimer()
        }
    }

    private func startMoveTimerIfNeeded() {
        guard moveReminderEnabled else { return }
        moveTimer = Timer.scheduledTimer(
            withTimeInterval: moveIntervalInSeconds,
            repeats: true
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.fireMoveReminder()
            }
        }
    }

    private func fireMoveReminder() {
        guard phase == .working, moveReminderEnabled else { return }
        moveReminderActive = true
        moveDismissTimer?.invalidate()
        moveDismissTimer = Timer.scheduledTimer(
            withTimeInterval: moveReminderDuration,
            repeats: false
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.moveReminderActive = false
            }
        }
    }

    private func stopMoveTimers() {
        moveTimer?.invalidate()
        moveTimer = nil
        moveDismissTimer?.invalidate()
        moveDismissTimer = nil
    }
}
