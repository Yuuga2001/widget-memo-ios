import SwiftUI

struct WatchMemoView: View {
    let store: MemoStore

    var body: some View {
        VStack(spacing: 0) {
            Text(store.boardName)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(store.textColor.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 2)

            ScrollView {
                Text(store.text)
                    .font(.system(size: store.fontSize))
                    .foregroundStyle(store.textColor)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.horizontal, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .background(store.backgroundColor.ignoresSafeArea())
    }
}
