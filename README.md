# MemoNow

**「ちょっとメモ。」そんな時に、これだけでいい。**

たった一枚の、最もシンプルでわかりやすいメモアプリ。
ホーム画面ウィジェットやロック画面ウィジェットに常時表示して、瞬時に確認。タップすれば瞬時に開いて、瞬時に書き換え。
買い物リスト、電話番号、合言葉——忘れたくない「ちょっとしたこと」を、いつでも目に留まる場所に。

## 機能

### メモ編集
- **一枚メモ × 4 ボード** — 画面全体がメモ帳。タブで 4 つのボードを切り替え
- **ボード名変更** — 画面上部のボード名をタップしてリネーム
- **Undo / Redo** — 左上の矢印ボタンで編集の取り消し・やり直し
- **クリップボードコピー** — コピーボタンでメモをワンタップコピー（トースト通知付き）

### ウィジェット
- **ホーム画面ウィジェット** — Small / Medium / Large
- **ロック画面ウィジェット** — Rectangular / Circular / Inline
- **ボード切り替え** — ウィジェットごとに表示ボードを選択可能
- **リアルタイム同期** — 書いた瞬間にウィジェットへ反映

### カスタマイズ
- **フォントサイズ調整** — 10pt〜48pt でスライダー調整
- **背景色・文字色** — カラーピッカーで自由に設定
- **グラデーション背景** — 設定色に基づいた上部濃・下部淡のグラデーション

### バックアップ
- **手動バックアップ** — 「現在の状態を保存」で任意のタイミングで保存
- **復元** — 過去のバックアップを選択して復元（復元前の状態は自動保存）
- **スワイプ削除** — 不要なバックアップは左スワイプで個別削除

### Apple Watch
- **自動同期** — iPhone で書いたメモが Apple Watch に自動反映
- **Watch アプリ** — 4 ボードすべてを Watch 上で閲覧

### その他
- **使い方ガイド** — アニメーション付きのインタラクティブなヘルプ画面
- **15 言語対応** — 英語・日本語・中国語(簡体/繁体)・韓国語・フランス語・ドイツ語・スペイン語・ポルトガル語・イタリア語・ロシア語・タイ語・インドネシア語・ベトナム語・アラビア語
- **データ管理** — ボード個別 / 全ボード一括のデータ削除

## 技術スタック

| 項目 | 詳細 |
|------|------|
| 言語 | Swift 5.10 |
| UI | SwiftUI |
| 最低 OS | iOS 17.0 / watchOS 10.0 |
| アーキテクチャ | @Observable Store パターン |
| データ共有 | App Groups + UserDefaults |
| Watch 連携 | WatchConnectivity |
| ローカリゼーション | String Catalog (.xcstrings) — 15 言語 |
| プロジェクト管理 | XcodeGen |
| テスト | Swift Testing + XCTest UI Tests |

## プロジェクト構造

```
WidgetMemo/
├── App/                    # エントリポイント (WidgetMemoApp)
├── Views/                  # UI レイヤー
│   ├── MainTabView         # 4 ボードのタブ切り替え
│   ├── MemoView            # メモ編集画面 (Undo/Redo, コピー, ツールバー)
│   ├── SettingsSheet       # 設定画面 (フォント, 色, データ削除)
│   ├── SnapshotSheetView   # バックアップ管理 (半モーダル)
│   ├── HelpGuideView       # 使い方ガイド (アコーディオン, アニメーション)
│   └── SafariView          # アプリ内ブラウザ
├── Shared/                 # Widget・Watch と共有
│   ├── MemoStore           # ボード単位のデータ管理 (@Observable)
│   ├── BoardManager        # 4 ボードの統括管理
│   ├── SnapshotStore       # バックアップの保存・復元・削除
│   ├── BoardSnapshot       # スナップショットのデータモデル
│   ├── AppConstants        # 定数・キー定義
│   └── WatchConnectivityService  # Watch 同期
└── Resources/              # Assets, Info.plist, Localizable.xcstrings

WidgetMemoWidget/           # Widget Extension
├── HomeScreenWidget        # systemSmall / Medium / Large
├── LockScreenWidget        # accessoryRectangular / Circular / Inline
├── SelectBoardIntent       # ウィジェットのボード選択 (AppIntent)
├── MemoTimelineProvider    # データ読み取り + Timeline 生成
├── MemoWidgetEntry         # TimelineEntry
└── Resources/              # Localizable.xcstrings, AppIntents.xcstrings

MemoNowWatch/               # watchOS アプリ
├── App/                    # WatchApp エントリポイント
├── Views/                  # WatchBoardListView, WatchMemoView
└── Resources/              # Localizable.xcstrings

WidgetMemoTests/            # ユニットテスト (78 件)
├── MemoStoreTests
├── BoardManagerTests
├── SnapshotStoreTests
├── TextUndoManagerTests
└── WatchConnectivityServiceTests

WidgetMemoUITests/          # UI テスト (25 件)
├── ToolbarUITests
├── SnapshotSheetUITests
└── UndoRedoUITests
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

# ユニットテスト (78 件)
xcodebuild test -scheme WidgetMemo -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:WidgetMemoTests

# UI テスト (25 件)
xcodebuild test -scheme WidgetMemo -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:WidgetMemoUITests

# 全テスト
xcodebuild test -scheme WidgetMemo -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## App Groups 設定

アプリとウィジェット間のデータ共有に App Groups を使用しています。
実機で動作させる場合は、Apple Developer ポータルで App Group ID `group.jp.riverapp.WidgetMemo` を登録してください。

## ライセンス

MIT
