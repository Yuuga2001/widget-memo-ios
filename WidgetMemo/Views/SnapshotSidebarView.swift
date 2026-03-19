import SwiftUI

struct SnapshotSidebarView: View {
    let store: MemoStore
    let snapshotStore: SnapshotStore
    @Binding var isPresented: Bool

    @State private var snapshots: [BoardSnapshot] = []
    @State private var showRestoreConfirm = false
    @State private var selectedSnapshot: BoardSnapshot?

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "yyyy/MM/dd HH:mm"
        return f
    }()

    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー
            HStack {
                Text("バージョン管理")
                    .font(.headline)
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isPresented = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                }
            }
            .padding()

            // 保存ボタン
            Button {
                snapshotStore.save(from: store)
                reloadSnapshots()
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("現在の状態を保存")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
            .accessibilityIdentifier("saveSnapshotButton")

            Divider()

            // スナップショット一覧
            if snapshots.isEmpty {
                Spacer()
                Text("保存された\nバージョンはありません")
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
        .background(.ultraThinMaterial)
        .onAppear {
            reloadSnapshots()
        }
        .alert("このバージョンに戻しますか？", isPresented: $showRestoreConfirm) {
            Button("キャンセル", role: .cancel) {
                selectedSnapshot = nil
            }
            Button("戻す") {
                if let snapshot = selectedSnapshot {
                    snapshotStore.restore(snapshot, to: store)
                    reloadSnapshots()
                }
                selectedSnapshot = nil
            }
        } message: {
            if let snapshot = selectedSnapshot {
                Text("\(dateFormatter.string(from: snapshot.date)) の状態に戻します。現在の状態は自動的に保存されます。")
            }
        }
    }

    private func reloadSnapshots() {
        snapshots = snapshotStore.snapshots(for: store.boardIndex)
    }
}
