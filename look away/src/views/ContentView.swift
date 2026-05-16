//
//  ContentView.swift
//  look away
//
//  Created by Vasiliy Smirnov on 5/16/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(SessionStore.self) private var store
    @State private var extendMinutes: Int = 5

    var body: some View {
        @Bindable var store = store

        VStack(spacing: 32) {
            Text("Look Away")
                .font(.system(size: 44, weight: .black, design: .rounded))

            switch store.phase {
            case .idle:
                Text("Take a break every \(store.workDurationMinutes) minutes.")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                VStack(spacing: 16) {
                    DurationField(
                        label: "Work duration (min)",
                        value: $store.workDurationMinutes
                    )
                    DurationField(
                        label: "Break duration (sec)",
                        value: $store.breakDurationSeconds
                    )

                    Divider()

                    Toggle(isOn: $store.blinkReminderEnabled) {
                        HStack(spacing: 6) {
                            Text("👀")
                            Text("Blink reminders")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .toggleStyle(.switch)

                    if store.blinkReminderEnabled {
                        DurationField(
                            label: "Blink every (min)",
                            value: $store.blinkIntervalMinutes
                        )
                    }

                    Toggle(isOn: $store.moveReminderEnabled) {
                        HStack(spacing: 6) {
                            Text("🤸")
                            Text("Move reminders")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .toggleStyle(.switch)

                    if store.moveReminderEnabled {
                        DurationField(
                            label: "Move every (min)",
                            value: $store.moveIntervalMinutes
                        )
                    }
                }
                .frame(maxWidth: 320)

                Button("Start session") {
                    store.start()
                }
                .controlSize(.extraLarge)
                .keyboardShortcut(.defaultAction)

            case .working, .onBreak:
                Text("Next break in")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Text(store.formattedTime)
                    .font(.system(size: 72, weight: .semibold, design: .monospaced))
                    .monospacedDigit()

                if store.phase == .working {
                    HStack(spacing: 8) {
                        TextField("", value: $extendMinutes, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                            .frame(width: 56)
                        Stepper("", value: $extendMinutes, in: 1...120)
                            .labelsHidden()
                        Button("Add \(extendMinutes) min") {
                            store.extendWork(byMinutes: extendMinutes)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                    }
                }

                Button("End session") {
                    store.endSession()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .controlSize(.large)
            }
        }
        .padding(60)
        .frame(minWidth: 420, minHeight: 600)
    }
}

private struct DurationField: View {
    let label: String
    @Binding var value: Int

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            TextField("", value: $value, format: .number)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            Stepper("", value: $value, in: 1...3600)
                .labelsHidden()
        }
    }
}

#Preview {
    ContentView()
        .environment(SessionStore())
}
