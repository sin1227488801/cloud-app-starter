# Pull Request作成ガイド

## 🎯 現在の状況

- **現在のブランチ**: `fix/app-deploy-workflow`
- **マージ先**: `main`
- **状態**: PRの手動作成が必要

## 🚀 PR作成手順

### 1. GitHubリポジトリにアクセス
https://github.com/sin1227488801/cloud-app-starter

### 2. PRの作成
1. **「Compare & pull request」ボタンをクリック**
   - ページ上部に黄色いバナーが表示されている場合
   
2. **または手動でPRを作成**
   - 「Pull requests」タブをクリック
   - 「New pull request」ボタンをクリック
   - base: `main` ← compare: `fix/app-deploy-workflow` を選択

### 3. PR情報の入力

**タイトル:**
```
feat: implement dynamic dashboard and fix deployment issues
```

**説明:**
```markdown
## 🚀 主な変更

### 動的ダッシュボードの実装
- リアルタイム更新機能（30秒間隔）
- インタラクティブなコマンドコピー機能
- レスポンシブデザイン・ダークモード対応
- システム状況のリアルタイム表示

### デプロイメント問題の修正
- ストレージアップロード権限エラーの解決
- 認証方式をストレージアカウントキーに統一
- Terraformバックエンド設定の重複解消

### 運用ツールの追加
- 包括的なトラブルシューティングガイド
- ワークフロー状況確認スクリプト
- 手動インポート・シークレット確認スクリプト

## 🎯 テスト済み項目
- [x] terraform-apply ワークフロー成功
- [x] app-deploy ワークフロー成功
- [x] 静的サイトデプロイ確認済み
- [x] 動的ダッシュボード準備完了

## 📋 マージ後の確認事項
1. 動的ダッシュボードの公開確認
2. リアルタイム更新機能の動作確認
3. コピー機能の動作確認

## 🔧 変更されたファイル
- `.github/workflows/app-deploy.yaml` - アップロード認証修正
- `.github/workflows/terraform-apply.yaml` - 認証方式統一
- `app/index.html` - 動的ダッシュボード実装
- `app/main.js` - リアルタイム更新機能
- `app/styles.css` - レスポンシブデザイン
- `app/meta.json` - デプロイメタデータ
- `docs/` - 包括的なドキュメント追加
- `scripts/` - 運用スクリプト追加
```

### 4. PRの作成・マージ
1. **「Create pull request」をクリック**
2. **レビュー（必要に応じて）**
3. **「Merge pull request」をクリック**
4. **「Confirm merge」をクリック**

## 🎉 マージ後の自動実行

マージが完了すると、以下が自動実行されます：

### 自動トリガー
- `app-deploy`ワークフローが自動実行される（app/**の変更を検知）
- 動的ダッシュボードがデプロイされる

### 確認方法
1. **GitHub Actions確認**
   - Actionsタブで実行状況を確認
   
2. **ウェブサイト確認**
   - https://cloudappdevlvupk0zb.z11.web.core.windows.net/
   - 動的ダッシュボードが表示されることを確認

## 🔍 期待される結果

### 動的ダッシュボードの機能
- ✨ **リアルタイム更新**: デプロイ情報が30秒ごとに更新
- 📋 **コピー機能**: コマンドをワンクリックでコピー
- 🌙 **ダークモード**: システム設定に自動追従
- 📱 **レスポンシブ**: モバイル・タブレット対応
- 🎨 **インタラクティブ**: ホバーエフェクト・アニメーション

### システム情報表示
- Storage Account名
- Website URL
- 最終デプロイ時刻
- Git SHA（コミットハッシュ）

## 🛠️ トラブルシューティング

### PRが作成できない場合
1. ブランチが正しくプッシュされているか確認
2. GitHubにログインしているか確認
3. リポジトリの権限があるか確認

### マージ後にワークフローが実行されない場合
1. Actionsタブで手動実行
2. `app-deploy` → `Run workflow` をクリック

### ウェブサイトが更新されない場合
1. ブラウザのキャッシュをクリア
2. 数分待ってから再アクセス
3. GitHub Actionsのログを確認

## 📞 サポート

問題が発生した場合：
1. `docs/error-troubleshooting.md` を参照
2. `bash scripts/check-workflow-status.sh` で状況確認
3. GitHub Actionsのログを確認