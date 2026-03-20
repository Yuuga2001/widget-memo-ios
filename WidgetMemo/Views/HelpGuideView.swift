import SwiftUI

struct HelpGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedSections: Set<Int> = [0]
    @State private var appeared = false

    private let sections: [(icon: String, title: LocalizedStringKey, accentColor: Color, steps: [LocalizedStringKey])] = [
        (
            icon: "hand.tap",
            title: "Quick Add from App Icon",
            accentColor: .blue,
            steps: [
                "Long press the MemoNow app icon on the home screen",
                "Select a widget size from the quick menu to add it instantly",
            ]
        ),
        (
            icon: "plus.square.on.square",
            title: "Add Widget from Home Screen",
            accentColor: .cyan,
            steps: [
                "Long press an empty area on the home screen",
                "Tap the \"+\" button in the upper left",
                "Type \"MemoNow\" in the search field",
                "Choose your preferred size and tap \"Add Widget\"",
            ]
        ),
        (
            icon: "arrow.triangle.2.circlepath",
            title: "Switching Widget Boards",
            accentColor: .green,
            steps: [
                "Long press the widget on the home screen",
                "Tap \"Edit Widget\"",
                "Tap \"Board\" and select the board you want to display",
            ]
        ),
        (
            icon: "lock.display",
            title: "Add Widget to Lock Screen",
            accentColor: .orange,
            steps: [
                "Long press the lock screen and tap \"Customize\"",
                "Select \"Lock Screen\"",
                "Tap the widget area",
                "Select MemoNow and add it",
            ]
        ),
        (
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
        ),
        (
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
        ),
        (
            icon: "applewatch",
            title: "Apple Watch Integration",
            accentColor: .indigo,
            steps: [
                "Memos written on iPhone sync to Apple Watch automatically",
                "Open the Watch app to view your memos instantly",
                "Check your memos on the go",
            ]
        ),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 1. Hero Header
                    headerView

                    // 2-5. Sections with disclosure, animation, timeline
                    ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                        sectionCard(index: index, section: section)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0.3)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.92)
                                    .offset(y: phase.isIdentity ? 0 : 20)
                            }
                    }
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
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    appeared = true
                }
            }
        }
    }

    // MARK: - Hero Header

    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "note.text")
                .font(.system(size: 44))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.bounce, value: appeared)

            Text("MemoNow")
                .font(.title2)
                .fontWeight(.bold)

            Text("Quick memo at a glance")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : -10)
    }

    // MARK: - Section Card

    private func sectionCard(index: Int, section: (icon: String, title: LocalizedStringKey, accentColor: Color, steps: [LocalizedStringKey])) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Tappable header
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    if expandedSections.contains(index) {
                        expandedSections.remove(index)
                    } else {
                        expandedSections.insert(index)
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: section.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(Circle().fill(section.accentColor))
                        .symbolEffect(.bounce, value: expandedSections.contains(index))

                    Text(section.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(expandedSections.contains(index) ? 90 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding()

            // Expandable steps with timeline
            if expandedSections.contains(index) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(section.steps.enumerated()), id: \.offset) { stepIndex, step in
                        HStack(alignment: .top, spacing: 12) {
                            // Timeline: circle + connecting line
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(section.accentColor)
                                    .frame(width: 22, height: 22)
                                    .overlay(
                                        Text("\(stepIndex + 1)")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(.white)
                                    )

                                if stepIndex < section.steps.count - 1 {
                                    Rectangle()
                                        .fill(section.accentColor.opacity(0.3))
                                        .frame(width: 2)
                                        .frame(maxHeight: .infinity)
                                }
                            }
                            .frame(width: 22)

                            Text(step)
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, stepIndex < section.steps.count - 1 ? 16 : 0)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [section.accentColor.opacity(0.08), section.accentColor.opacity(0.02)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
