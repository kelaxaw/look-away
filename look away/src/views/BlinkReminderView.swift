//
//  BlinkReminderView.swift
//  look away
//

import SwiftUI

struct BlinkReminderView: View {
    private let toggleInterval: TimeInterval = 0.45

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.18)
                .ignoresSafeArea()

            TimelineView(.periodic(from: .now, by: toggleInterval)) { context in
                let step = Int(context.date.timeIntervalSinceReferenceDate / toggleInterval)
                let closed = step.isMultiple(of: 2)

                VStack(spacing: 28) {
                    Text(closed ? "🙈" : "👀")
                        .font(.system(size: 200))
                        .scaleEffect(closed ? 0.92 : 1.0)
                        .animation(.easeInOut(duration: toggleInterval), value: closed)
                        .shadow(color: .black.opacity(0.5), radius: 20)

                    Text("Blink!")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.6), radius: 8)

                    Text("Rest your eyes for a moment")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .transition(.opacity)
        }
    }
}

#Preview {
    BlinkReminderView()
        .frame(width: 800, height: 500)
        .background(Color.gray)
}
