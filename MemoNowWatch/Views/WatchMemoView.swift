import SwiftUI

struct WatchMemoView: View {
    let store: MemoStore

    @State private var crownFontSize: Double = AppConstants.watchDefaultFontSize
    @State private var isInitialized = false

    /// Watch ローカルの UserDefaults にフォントサイズを永続化（iPhone とは独立）
    private var watchDefaults: UserDefaults { .standard }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(store.boardName)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(store.textColor.opacity(0.7))
                .padding(.horizontal, 4)
                .padding(.top, 2)

            ScrollView {
                Text(store.text)
                    .font(.system(size: crownFontSize))
                    .foregroundStyle(store.textColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(store.backgroundColor)
        .focusable()
        .digitalCrownRotation(
            $crownFontSize,
            from: AppConstants.watchMinFontSize,
            through: AppConstants.watchMaxFontSize,
            by: 1.0,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: crownFontSize) { _, newValue in
            // Watch ローカルに保存（iPhone には影響しない）
            watchDefaults.set(newValue, forKey: AppConstants.watchFontSizeKey(for: store.boardIndex))
        }
        .onAppear {
            guard !isInitialized else { return }
            isInitialized = true

            // Watch ローカルに保存済みのサイズがあればそれを使用
            let savedSize = watchDefaults.double(forKey: AppConstants.watchFontSizeKey(for: store.boardIndex))
            if savedSize > 0 {
                crownFontSize = savedSize
            } else {
                // 初回は iPhone のサイズをスケーリングして初期値に
                crownFontSize = min(
                    max(store.fontSize * 0.6, AppConstants.watchMinFontSize),
                    AppConstants.watchMaxFontSize
                )
            }
        }
    }
}
