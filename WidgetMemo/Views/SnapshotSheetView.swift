import SwiftUI

struct SnapshotSheetView: View {
    let store: MemoStore
    let snapshotStore: SnapshotStore
    @Environment(\.dismiss) private var dismiss

    @State private var snapshots: [BoardSnapshot] = []
    @State private var showRestoreConfirm = false
    @State private var selectedSnapshot: BoardSnapshot?

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 保存ボタン
                Button {
                    snapshotStore.save(from: store)
                    reloadSnapshots()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save Current State")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .accessibilityIdentifier("saveSnapshotButton")

                Divider()

                // スナップショット一覧
                if snapshots.isEmpty {
                    Spacer()
                    Text("No backups\navailable")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Spacer()
                } else {
                    List {
                        ForEach(snapshots) { snapshot in
                            Button {
                                selectedSnapshot = snapshot
                                showRestoreConfirm = true
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(dateFormatter.string(from: snapshot.date))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(snapshot.text.prefix(40).replacingOccurrences(of: "\n", with: " "))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                .padding(.vertical, 2)
                            }
                            .foregroundStyle(.primary)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                snapshotStore.delete(snapshots[index], for: store.boardIndex)
                            }
                            reloadSnapshots()
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Backups")
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
                reloadSnapshots()
            }
            .alert("Restore this state?", isPresented: $showRestoreConfirm) {
                Button("Cancel", role: .cancel) {
                    selectedSnapshot = nil
                }
                Button("Restore") {
                    if let snapshot = selectedSnapshot {
                        snapshotStore.restore(snapshot, to: store)
                        reloadSnapshots()
                    }
                    selectedSnapshot = nil
                }
            } message: {
                if let snapshot = selectedSnapshot {
                    Text("Restoring to \(dateFormatter.string(from: snapshot.date)). Current state will be saved automatically.")
                }
            }
        }
    }

    private func reloadSnapshots() {
        snapshots = snapshotStore.snapshots(for: store.boardIndex)
    }
}
