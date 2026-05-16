//
//  BreakOverlayController.swift
//  look away
//

import AppKit
import SwiftUI

@MainActor
final class BreakOverlayController {
    private var windows: [NSWindow] = []
    private var screenObserver: NSObjectProtocol?
    private weak var activeStore: SessionStore?

    func show(store: SessionStore) {
        guard windows.isEmpty else { return }
        activeStore = store
        buildWindows(for: store)
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.rebuildIfNeeded()
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
        activeStore = nil
    }

    private func rebuildIfNeeded() {
        guard let store = activeStore else { return }
        for window in windows {
            window.orderOut(nil)
        }
        windows.removeAll()
        buildWindows(for: store)
    }

    private func buildWindows(for store: SessionStore) {
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
            window.ignoresMouseEvents = false
            window.collectionBehavior = [
                .canJoinAllSpaces,
                .fullScreenAuxiliary,
                .stationary,
                .ignoresCycle
            ]
            window.contentView = NSHostingView(
                rootView: BreakOverlayView(store: store)
            )
            window.setFrame(screen.frame, display: true)
            window.makeKeyAndOrderFront(nil)
            windows.append(window)
        }
        NSApp.activate(ignoringOtherApps: true)
    }
}
