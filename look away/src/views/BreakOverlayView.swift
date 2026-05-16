//
//  BreakOverlayView.swift
//  look away
//

import SwiftUI

struct BreakOverlayView: View {
    let store: SessionStore

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                Text("Touch the grass bro 🌿")
                    .font(.system(size: 88, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .shadow(radius: 8)

                Text(store.formattedTime)
                    .font(.system(size: 56, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.secondary)

                Spacer()

                HStack(spacing: 24) {
                    Button("Skip break") {
                        store.skipBreak()
                    }
                    .controlSize(.extraLarge)

                    Button("End session") {
                        store.endSession()
                    }
                    .controlSize(.extraLarge)
                }
                .padding(.bottom, 80)
            }
            .padding(40)
        }
    }
}
