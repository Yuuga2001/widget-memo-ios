import SwiftUI

struct HelpGuideView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    helpSection(
                        icon: "plus.square.on.square",
                        title: "ウィジェットの追加方法",
                        accentColor: .blue,
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
                        accentColor: .green,
                        steps: [
                            "ホーム画面のウィジェットを長押しします",
                            "「ウィジェットを編集」をタップします",
                            "「ボード」をタップして、表示したいボードを選びます",
                        ]
                    )

                    helpSection(
                        icon: "lock.display",
                        title: "ロック画面にウィジェットを追加",
                        accentColor: .orange,
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
                        accentColor: .purple,
                        steps: [
                            "左上の矢印ボタンで「元に戻す」「やり直し」ができます",
                            "左上の時計ボタンでメモのバックアップを管理できます",
                            "右上のコピーボタンでメモをクリップボードにコピーできます",
                            "画面上部のボード名をタップすると名前を変更できます",
                            "右上の歯車ボタンで文字サイズや色をカスタマイズできます",
                            "画面下のタブで 4 つのボードを切り替えられます",
                        ]
                    )

                    helpSection(
                        icon: "clock.arrow.circlepath",
                        title: "バックアップの使い方",
                        accentColor: .teal,
                        steps: [
                            "左上の時計ボタンをタップしてバックアップを開きます",
                            "「現在の状態を保存」ボタンでメモの状態を記録できます",
                            "一覧から過去の保存を選ぶと、その時の状態に戻せます",
                            "復元する際、現在の状態は自動的に保存されるので安心です",
                            "不要な履歴は左スワイプで削除できます",
                        ]
                    )

                    helpSection(
                        icon: "applewatch",
                        title: "Apple Watch との連携",
                        accentColor: .indigo,
                        steps: [
                            "iPhone で書いたメモは Apple Watch に自動で同期されます",
                            "Watch アプリを開くとすぐにメモを確認できます",
                            "外出先で手軽にメモをチェックできます",
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

    private func helpSection(icon: String, title: String, accentColor: Color, steps: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(accentColor))

                Text(title)
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(index + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 22, height: 22)
                            .background(Circle().fill(accentColor))

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
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [accentColor.opacity(0.08), accentColor.opacity(0.03)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}
