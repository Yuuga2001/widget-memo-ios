# WidgetMemo

シンプルな1枚メモアプリ。ホーム画面ウィジェット・ロック画面ウィジェット対応。

## 機能

- **フルスクリーンメモ** — 画面全体がメモ帳。タップしてすぐ入力
- **ウィジェット対応** — メモ内容の冒頭をウィジェットに表示
  - ホーム画面: Small / Medium / Large
  - ロック画面: Rectangular / Circular / Inline
- **フォントサイズ調整** — 10pt〜48ptでスライダー調整
- **背景色・文字色カスタマイズ** — カラーピッカーで自由に設定
- **リアルタイム同期** — アプリの変更がウィジェットに自動反映

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
