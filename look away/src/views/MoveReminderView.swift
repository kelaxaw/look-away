//
//  MoveReminderView.swift
//  look away
//

import SwiftUI

struct MoveReminderView: View {
    private let rotationsPerSecond: Double = 1.2
    private let driftAmplitude: CGFloat = 40

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.18)
                .ignoresSafeArea()

            TimelineView(.animation) { context in
                let t = context.date.timeIntervalSinceReferenceDate
                let angle = (t * 360 * rotationsPerSecond).truncatingRemainder(dividingBy: 360)
                let bob = CGFloat(sin(t * 2 * .pi * rotationsPerSecond)) * driftAmplitude

                VStack(spacing: 28) {
                    Text("🤸")
                        .font(.system(size: 200))
                        .rotationEffect(.degrees(angle))
                        .offset(y: bob)
                        .shadow(color: .black.opacity(0.5), radius: 20)

                    Text("Move it!")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.6), radius: 8)

                    Text("Stand up and stretch for a minute")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
        }
    }
}

#Preview {
    MoveReminderView()
        .frame(width: 800, height: 500)
        .background(Color.gray)
}
