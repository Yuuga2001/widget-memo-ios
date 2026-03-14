# QuickNote

**「ちょっとメモ。」そんな時に、これだけでいい。**

たった一枚の、最もシンプルでわかりやすいメモアプリ。
ホーム画面ウィジェットやロック画面ウィジェットに常時表示して、瞬時に確認。タップすれば瞬時に開いて、瞬時に書き換え。
買い物リスト、電話番号、合言葉——忘れたくない「ちょっとしたこと」を、いつでも目に留まる場所に。

## 機能

- **一枚メモ** — 余計なものは何もない。画面全体がメモ帳。タップしてすぐ入力
- **ウィジェット常時表示** — メモ内容をホーム画面・ロック画面にいつでも表示
  - ホーム画面: Small / Medium / Large
  - ロック画面: Rectangular / Circular / Inline
- **フォントサイズ調整** — 10pt〜48ptでスライダー調整
- **背景色・文字色カスタマイズ** — カラーピッカーで自由に設定
- **グラデーション背景** — 設定色に基づいた上部濃・下部淡のグラデーション
- **リアルタイム同期** — 書いた瞬間にウィジェットへ反映。アプリを閉じても即時更新

## 技術スタック

| 項目 | 詳細 |
|------|------|
| 言語 | Swift 5.10 |
| UI | SwiftUI |
| 最低OS | iOS 17.0 |
| アーキテクチャ | @Observable Store パターン |
| データ共有 | App Groups + UserDefaults |
| プロジェクト管理 | XcodeGen |
| テスト | Swift Testing |

## プロジェクト構造

```
WidgetMemo/
├── App/                    # エントリポイント
├── Views/                  # MemoView, SettingsSheet
├── Shared/                 # MemoStore, AppConstants (Widget と共有)
└── Resources/              # Assets, Info.plist

WidgetMemoWidget/           # Widget Extension
├── HomeScreenWidget        # systemSmall/Medium/Large
├── LockScreenWidget        # accessoryRectangular/Circular/Inline
├── MemoTimelineProvider    # データ読み取り + Timeline 生成
└── MemoWidgetEntry         # TimelineEntry

WidgetMemoTests/            # ユニットテスト
```

## セットアップ

```bash
# XcodeGen でプロジェクト生成
brew install xcodegen  # 未インストールの場合
xcodegen generate

# Xcode で開く
open WidgetMemo.xcodeproj

# アイコン再生成（Pillow 必要）
python3 generate_icon.py
```

## ビルド & テスト

```bash
# ビルド
xcodebuild build -scheme WidgetMemo -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# テスト
xcodebuild test -scheme WidgetMemo -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## App Groups 設定

アプリとウィジェット間のデータ共有に App Groups を使用しています。
実機で動作させる場合は、Apple Developer ポータルで App Group ID `group.jp.riverapp.WidgetMemo` を登録してください。

## ライセンス

MIT
