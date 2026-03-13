import SwiftUI

struct SettingsSheet: View {
    @Environment(MemoStore.self) private var store
    @Environment(\.dismiss) private var dismiss

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
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
