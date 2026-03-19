import SwiftUI

struct SettingsSheet: View {
    @Environment(MemoStore.self) private var store
    @Environment(BoardManager.self) private var manager
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm = false
    @State private var showDeleteAllConfirm = false
    @State private var safariURL: URL?

    var body: some View {
        @Bindable var store = store

        NavigationStack {
            Form {
                Section("フォントサイズ") {
                    HStack {
                        Text("A")
                            .font(.system(size: 12))
                        Slider(
                            value: $store.fontSize,
                            in: AppConstants.minFontSize...AppConstants.maxFontSize,
                            step: 1
                        )
                        Text("A")
                            .font(.system(size: 24))
                    }
                    Text("現在: \(Int(store.fontSize))pt")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("背景色") {
                    ColorPicker("背景色を選択", selection: $store.backgroundColor, supportsOpacity: false)
                }

                Section("文字色") {
                    ColorPicker("文字色を選択", selection: $store.textColor, supportsOpacity: false)
                }

                Section("プレビュー") {
                    Text(store.text.isEmpty ? "メモのプレビュー" : String(store.text.prefix(100)))
                        .font(.system(size: store.fontSize))
                        .foregroundStyle(store.textColor)
                        .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
                        .padding(8)
                        .background(store.backgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                Section {
                    Button("デフォルト設定に戻す") {
                        store.resetToDefaults()
                    }

                    Button("このボードのデータを削除", role: .destructive) {
                        showDeleteConfirm = true
                    }

                    Button("すべてのデータを削除", role: .destructive) {
                        showDeleteAllConfirm = true
                    }
                }

                Section {
                    Button {
                        safariURL = AppConstants.aboutURL
                    } label: {
                        HStack {
                            Text("MemoNow について")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Button {
                        safariURL = AppConstants.privacyPolicyURL
                    } label: {
                        HStack {
                            Text("プライバシーポリシー")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Button {
                        safariURL = AppConstants.contactURL
                    } label: {
                        HStack {
                            Text("お問い合わせ")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") { dismiss() }
                }
            }
            .alert("データを削除しますか？", isPresented: $showDeleteConfirm) {
                Button("キャンセル", role: .cancel) {}
                Button("削除する", role: .destructive) {
                    store.deleteAllData()
                }
            } message: {
                Text("このボードのメモ内容・設定・ボード名・バックアップがすべて初期化されます。この操作は取り消せません。")
            }
            .alert("すべてのデータを削除しますか？", isPresented: $showDeleteAllConfirm) {
                Button("キャンセル", role: .cancel) {}
                Button("すべて削除する", role: .destructive) {
                    manager.deleteAllData()
                    dismiss()
                }
            } message: {
                Text("全 4 ボードのメモ内容・設定・ボード名・バックアップがすべて初期化されます。この操作は取り消せません。")
            }
        }
        .presentationDetents([.medium, .large])
        .sheet(item: $safariURL) { url in
            SafariView(url: url)
                .ignoresSafeArea()
        }
    }
}
