import SwiftUI

struct WatchMemoView: View {
    let store: MemoStore

    var body: some View {
        ScrollView {
            Text(store.text)
                .font(.system(size: store.fontSize))
                .foregroundStyle(store.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .background(store.backgroundColor.ignoresSafeArea())
    }
}
