import SwiftUI

struct WatchMemoView: View {
    let store: MemoStore

    @State private var crownFontSize: Double = AppConstants.watchDefaultFontSize

    var body: some View {
        ScrollView {
            Text(store.text)
                .font(.system(size: crownFontSize))
                .foregroundStyle(store.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
        }
        .background(store.backgroundColor)
        .navigationTitle(store.boardName)
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
        .onAppear {
            // iPhone のフォントサイズを初期値としてスケーリング
            crownFontSize = min(
                max(store.fontSize * 0.6, AppConstants.watchMinFontSize),
                AppConstants.watchMaxFontSize
            )
        }
    }
}
