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
                Section("Font Size") {
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
                    Text("Current: \(Int(store.fontSize))pt")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Background Color") {
                    ColorPicker("Select Background Color", selection: $store.backgroundColor, supportsOpacity: false)
                }

                Section("Text Color") {
                    ColorPicker("Select Text Color", selection: $store.textColor, supportsOpacity: false)
                }

                Section("Preview") {
                    Text(store.text.isEmpty ? String(localized: "Memo Preview") : String(store.text.prefix(100)))
                        .font(.system(size: store.fontSize))
                        .foregroundStyle(store.textColor)
                        .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
                        .padding(8)
                        .background(store.backgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                Section {
                    Button("Reset to Defaults") {
                        store.resetToDefaults()
                    }

                    Button("Delete This Board's Data", role: .destructive) {
                        showDeleteConfirm = true
                    }

                    Button("Delete All Data", role: .destructive) {
                        showDeleteAllConfirm = true
                    }
                }

                Section {
                    Button {
                        safariURL = AppConstants.aboutURL
                    } label: {
                        HStack {
                            Text("About MemoNow")
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
                            Text("Privacy Policy")
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
                            Text("Contact Us")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Delete Data?", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    store.deleteAllData()
                }
            } message: {
                Text("This board's memo, settings, board name, and backups will all be reset. This cannot be undone.")
            }
            .alert("Delete All Data?", isPresented: $showDeleteAllConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete All", role: .destructive) {
                    manager.deleteAllData()
                    dismiss()
                }
            } message: {
                Text("All 4 boards' memo, settings, board names, and backups will all be reset. This cannot be undone.")
            }
        }
        .presentationDetents([.medium, .large])
        .sheet(item: $safariURL) { url in
            SafariView(url: url)
                .ignoresSafeArea()
        }
    }
}
