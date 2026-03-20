import SwiftUI

struct HelpGuideView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    helpSection(
                        icon: "plus.square.on.square",
                        title: "How to Add Widgets",
                        accentColor: .blue,
                        steps: [
                            "Long press an empty area on the home screen",
                            "Tap the \"+\" button in the upper left",
                            "Type \"MemoNow\" in the search field",
                            "Choose your preferred size and tap \"Add Widget\"",
                        ]
                    )

                    helpSection(
                        icon: "arrow.triangle.2.circlepath",
                        title: "Switching Widget Boards",
                        accentColor: .green,
                        steps: [
                            "Long press the widget on the home screen",
                            "Tap \"Edit Widget\"",
                            "Tap \"Board\" and select the board you want to display",
                        ]
                    )

                    helpSection(
                        icon: "lock.display",
                        title: "Add Widget to Lock Screen",
                        accentColor: .orange,
                        steps: [
                            "Long press the lock screen and tap \"Customize\"",
                            "Select \"Lock Screen\"",
                            "Tap the widget area",
                            "Select MemoNow and add it",
                        ]
                    )

                    helpSection(
                        icon: "pencil.and.outline",
                        title: "Memo Editing Tips",
                        accentColor: .purple,
                        steps: [
                            "Use the arrow buttons in the upper left to undo/redo",
                            "Use the clock button in the upper left to manage backups",
                            "Use the copy button in the upper right to copy memo to clipboard",
                            "Tap the board name at the top to rename it",
                            "Use the gear button in the upper right to customize font size and colors",
                            "Switch between 4 boards using the tabs at the bottom",
                        ]
                    )

                    helpSection(
                        icon: "clock.arrow.circlepath",
                        title: "How to Use Backups",
                        accentColor: .teal,
                        steps: [
                            "Tap the clock button in the upper left to open backups",
                            "Use the \"Save Current State\" button to record your memo",
                            "Select a past backup from the list to restore it",
                            "Your current state is saved automatically when restoring",
                            "Swipe left on unwanted backups to delete them",
                        ]
                    )

                    helpSection(
                        icon: "applewatch",
                        title: "Apple Watch Integration",
                        accentColor: .indigo,
                        steps: [
                            "Memos written on iPhone sync to Apple Watch automatically",
                            "Open the Watch app to view your memos instantly",
                            "Check your memos on the go",
                        ]
                    )
                }
                .padding()
            }
            .navigationTitle("How to Use")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func helpSection(icon: String, title: LocalizedStringKey, accentColor: Color, steps: [LocalizedStringKey]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(accentColor))

                Text(title)
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(index + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 22, height: 22)
                            .background(Circle().fill(accentColor))

                        Text(step)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.leading, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [accentColor.opacity(0.08), accentColor.opacity(0.03)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}
