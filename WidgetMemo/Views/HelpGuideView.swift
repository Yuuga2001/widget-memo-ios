import SwiftUI

struct HelpGuideView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    helpSection(
                        icon: "plus.square.on.square",
                        title: "ウィジェットの追加方法",
                        steps: [
                            "ホーム画面の空白部分を長押しします",
                            "左上の「＋」ボタンをタップします",
                            "検索欄に「MemoNow」と入力します",
                            "お好みのサイズを選んで「ウィジェットを追加」をタップします",
                        ]
                    )

                    helpSection(
                        icon: "arrow.triangle.2.circlepath",
                        title: "ウィジェットのボード切り替え",
                        steps: [
                            "ホーム画面のウィジェットを長押しします",
                            "「ウィジェットを編集」をタップします",
                            "「ボード」をタップして、表示したいボードを選びます",
                        ]
                    )

                    helpSection(
                        icon: "lock.display",
                        title: "ロック画面にウィジェットを追加",
                        steps: [
                            "ロック画面を長押しして「カスタマイズ」をタップします",
                            "「ロック画面」を選びます",
                            "ウィジェットエリアをタップします",
                            "MemoNow を選んで追加します",
                        ]
                    )

                    helpSection(
                        icon: "pencil.and.outline",
                        title: "メモ編集のヒント",
                        steps: [
                            "左上の矢印ボタンで「元に戻す」「やり直し」ができます",
                            "画面上部のボード名をタップすると名前を変更できます",
                            "右上の歯車アイコンで文字サイズや色をカスタマイズできます",
                            "画面下のタブで 4 つのボードを切り替えられます",
                        ]
                    )
                }
                .padding()
            }
            .navigationTitle("使い方ガイド")
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
        }
    }

    private func helpSection(icon: String, title: String, steps: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(index + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 22, height: 22)
                            .background(Circle().fill(.blue))

                        Text(step)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.leading, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}
