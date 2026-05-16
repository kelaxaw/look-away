//
//  PreBreakToolbarView.swift
//  look away
//

import SwiftUI

struct PreBreakToolbarView: View {
    let store: SessionStore
    @State private var extendMinutes: Int = 5

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "eye.fill")
                .font(.title2)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("Break in \(store.secondsRemaining)s")
                    .font(.headline)
                Text("Touch the grass bro is coming")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 16)

            HStack(spacing: 6) {
                TextField("", value: $extendMinutes, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .frame(width: 44)
                Stepper("", value: $extendMinutes, in: 1...120)
                    .labelsHidden()
                Button("Extend +\(extendMinutes) min") {
                    store.extendWork(byMinutes: extendMinutes)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }

            Button("End session") {
                store.endSession()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(radius: 12, y: 4)
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }
}
