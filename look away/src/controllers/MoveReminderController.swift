//
//  MoveReminderController.swift
//  look away
//

import AppKit
import SwiftUI

@MainActor
final class MoveReminderController {
    private var windows: [NSWindow] = []
    private var screenObserver: NSObjectProtocol?

    func show() {
        guard windows.isEmpty else { return }
        buildWindows()
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.rebuild()
            }
        }
    }

    func hide() {
        if let observer = screenObserver {
            NotificationCenter.default.removeObserver(observer)
            screenObserver = nil
        }
        for window in windows {
            window.orderOut(nil)
        }
        windows.removeAll()
    }

    private func rebuild() {
        for window in windows {
            window.orderOut(nil)
        }
        windows.removeAll()
        buildWindows()
    }

    private func buildWindows() {
        for screen in NSScreen.screens {
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: .borderless,
                backing: .buffered,
                defer: false,
                screen: screen
            )
            window.isReleasedWhenClosed = false
            window.level = .screenSaver
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false
            window.ignoresMouseEvents = true
            window.collectionBehavior = [
                .canJoinAllSpaces,
                .fullScreenAuxiliary,
                .stationary,
                .ignoresCycle
            ]
            window.contentView = NSHostingView(rootView: MoveReminderView())
            window.setFrame(screen.frame, display: true)
            window.orderFrontRegardless()
            windows.append(window)
        }
    }
}
