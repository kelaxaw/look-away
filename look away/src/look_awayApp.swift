//
//  look_awayApp.swift
//  look away
//
//  Created by Vasiliy Smirnov on 5/16/26.
//

import AppKit
import Observation
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let store = SessionStore()

    private lazy var overlayController = BreakOverlayController()
    private lazy var toolbarController = PreBreakToolbarController()
    private lazy var blinkController = BlinkReminderController()
    private lazy var moveController = MoveReminderController()

    private var statusItem: NSStatusItem?
    private var popover: NSPopover?

    private var lastBlinkEnabled = true
    private var lastBlinkInterval = 1
    private var lastMoveEnabled = true
    private var lastMoveInterval = 15

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupStatusItem()
        setupPopover()
        lastBlinkEnabled = store.blinkReminderEnabled
        lastBlinkInterval = store.blinkIntervalMinutes
        lastMoveEnabled = store.moveReminderEnabled
        lastMoveInterval = store.moveIntervalMinutes
        trackStore()
    }

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.target = self
            button.action = #selector(togglePopover(_:))
            button.imagePosition = .imageLeading
        }
        statusItem = item
        refreshStatusItem()
    }

    private func setupPopover() {
        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 480, height: 560)
        popover.contentViewController = NSHostingController(
            rootView: ContentView().environment(store)
        )
        self.popover = popover
    }

    @objc private func togglePopover(_ sender: Any?) {
        guard let popover, let button = statusItem?.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func trackStore() {
        withObservationTracking {
            _ = store.phase
            _ = store.secondsRemaining
            _ = store.blinkReminderActive
            _ = store.moveReminderActive
            _ = store.blinkReminderEnabled
            _ = store.blinkIntervalMinutes
            _ = store.moveReminderEnabled
            _ = store.moveIntervalMinutes
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.handleStoreChange()
                self?.trackStore()
            }
        }
    }

    private func handleStoreChange() {
        switch store.phase {
        case .onBreak:
            overlayController.show(store: store)
        case .idle, .working:
            overlayController.hide()
        }
        if store.phase != .working {
            toolbarController.hide()
            blinkController.hide()
            moveController.hide()
        }

        if store.shouldShowPreBreakToolbar {
            toolbarController.show(store: store)
        } else if store.phase != .working || store.secondsRemaining > 30 {
            toolbarController.hide()
        }

        if store.blinkReminderActive {
            blinkController.show()
        } else {
            blinkController.hide()
        }

        if store.moveReminderActive {
            moveController.show()
        } else {
            moveController.hide()
        }

        if store.blinkReminderEnabled != lastBlinkEnabled
            || store.blinkIntervalMinutes != lastBlinkInterval {
            lastBlinkEnabled = store.blinkReminderEnabled
            lastBlinkInterval = store.blinkIntervalMinutes
            store.restartBlinkScheduling()
        }
        if store.moveReminderEnabled != lastMoveEnabled
            || store.moveIntervalMinutes != lastMoveInterval {
            lastMoveEnabled = store.moveReminderEnabled
            lastMoveInterval = store.moveIntervalMinutes
            store.restartMoveScheduling()
        }

        refreshStatusItem()
    }

    private func refreshStatusItem() {
        guard let button = statusItem?.button else { return }
        let symbolName: String
        let title: String
        switch store.phase {
        case .idle:
            symbolName = "eye.fill"
            title = ""
        case .working:
            symbolName = "eye.fill"
            title = " " + store.formattedMinutes
        case .onBreak:
            symbolName = "leaf.fill"
            title = " " + store.formattedTime
        }
        button.image = NSImage(
            systemSymbolName: symbolName,
            accessibilityDescription: "Look away"
        )
        button.title = title
    }
}

@main
struct look_awayApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

