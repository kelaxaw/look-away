//
//  PreBreakToolbarController.swift
//  look away
//

import AppKit
import SwiftUI

@MainActor
final class PreBreakToolbarController {
    private var panel: NSPanel?

    func show(store: SessionStore) {
        guard panel == nil else { return }
        guard let screen = NSScreen.main else { return }

        let hosting = NSHostingView(rootView: PreBreakToolbarView(store: store))
        hosting.translatesAutoresizingMaskIntoConstraints = false

        let panelWidth: CGFloat = 620
        let panelHeight: CGFloat = 80
        let originX = screen.visibleFrame.midX - panelWidth / 2
        let originY = screen.visibleFrame.maxY - panelHeight - 16

        let panel = NSPanel(
            contentRect: NSRect(x: originX, y: originY, width: panelWidth, height: panelHeight),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isReleasedWhenClosed = false
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.isMovableByWindowBackground = false
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]
        panel.becomesKeyOnlyIfNeeded = true
        panel.contentView = hosting
        panel.orderFrontRegardless()

        self.panel = panel
    }

    func hide() {
        panel?.orderOut(nil)
        panel = nil
    }
}
