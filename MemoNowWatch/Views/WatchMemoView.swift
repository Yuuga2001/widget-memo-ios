import SwiftUI

struct WatchMemoView: View {
    let store: MemoStore

    @State private var crownFontSize: Double = AppConstants.watchDefaultFontSize

    /// Watch ローカルの UserDefaults にフォントサイズを永続化（iPhone とは独立）
    private var watchDefaults: UserDefaults { .standard }

    private var savedFontSize: Double {
        let saved = watchDefaults.double(forKey: AppConstants.watchFontSizeKey(for: store.boardIndex))
        if saved > 0 { return saved }
        return min(
            max(store.fontSize * 0.6, AppConstants.watchMinFontSize),
            AppConstants.watchMaxFontSize
        )
    }

    init(store: MemoStore) {
        self.store = store
        // init 時に UserDefaults から読み込んで @State の初期値に設定
        let defaults = UserDefaults.standard
        let saved = defaults.double(forKey: AppConstants.watchFontSizeKey(for: store.boardIndex))
        if saved > 0 {
            _crownFontSize = State(initialValue: saved)
        } else {
            let scaled = min(
                max(store.fontSize * 0.6, AppConstants.watchMinFontSize),
                AppConstants.watchMaxFontSize
            )
            _crownFontSize = State(initialValue: scaled)
        }
    }

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
            watchDefaults.set(newValue, forKey: AppConstants.watchFontSizeKey(for: store.boardIndex))
        }
    }
}
