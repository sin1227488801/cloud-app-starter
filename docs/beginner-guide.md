# 🚀 初心者向け完全ガイド - ワンクリックでWebサイトを作ろう！

## 📖 このガイドについて

**プログラミング経験ゼロでもOK！** このガイドに従えば、誰でも簡単に：
- ✨ 美しいWebサイトを作成
- 🌐 インターネットに公開
- 🗑️ 不要になったら完全削除

**所要時間**: 約30分（初回のみ）
**費用**: ほぼ無料（月数円程度）

---

## 🎯 Step 1: 事前準備（初回のみ）

### 1-1. 必要なアカウント作成

#### ✅ GitHubアカウント
1. https://github.com にアクセス
2. 「Sign up」をクリック
3. メールアドレス、パスワードを入力
4. 認証メールを確認

#### ✅ Azureアカウント（無料）
1. https://azure.microsoft.com/free/ にアクセス
2. 「無料で始める」をクリック
3. Microsoftアカウントでサインイン
4. クレジットカード情報入力（無料枠内なら課金されません）

### 1-2. Azure設定（5分）

#### Service Principal作成
1. **Azure Portal** (https://portal.azure.com) にログイン
2. 検索バーで「Azure Active Directory」を検索
3. 左メニュー「アプリの登録」→「新規登録」
4. 名前: `cloud-app-starter-sp` と入力
5. 「登録」をクリック

#### 認証情報取得
1. 作成したアプリをクリック
2. **アプリケーション（クライアント）ID** をコピー → メモ帳に保存
3. **ディレクトリ（テナント）ID** をコピー → メモ帳に保存
4. 左メニュー「証明書とシークレット」
5. 「新しいクライアントシークレット」
6. 説明: `cloud-app-starter`、期限: 24か月
7. **値** をコピー → メモ帳に保存（⚠️ 一度しか表示されません）

#### サブスクリプションID取得
1. Azure Portal検索バーで「サブスクリプション」
2. 使用するサブスクリプションをクリック
3. **サブスクリプションID** をコピー → メモ帳に保存

#### 権限設定
1. サブスクリプション画面で「アクセス制御（IAM）」
2. 「追加」→「ロールの割り当ての追加」
3. ロール: **共同作成者** を選択
4. メンバー: 作成したService Principal（`cloud-app-starter-sp`）を選択
5. 「確認と割り当て」

---

## 🎯 Step 2: プロジェクト準備

### 2-1. リポジトリをフォーク

1. https://github.com/sin1227488801/cloud-app-starter にアクセス
2. 右上の「Fork」ボタンをクリック
3. 自分のアカウントにフォーク

### 2-2. GitHubシークレット設定

1. **自分のフォークしたリポジトリ** にアクセス
2. 「Settings」タブをクリック
3. 左メニュー「Secrets and variables」→「Actions」
4. 「New repository secret」で以下を追加：

| シークレット名 | 値 | 説明 |
|---|---|---|
| `ARM_CLIENT_ID` | Step 1-2でメモしたアプリケーションID | Azure認証用 |
| `ARM_CLIENT_SECRET` | Step 1-2でメモしたクライアントシークレット | Azure認証用 |
| `ARM_SUBSCRIPTION_ID` | Step 1-2でメモしたサブスクリプションID | Azure認証用 |
| `ARM_TENANT_ID` | Step 1-2でメモしたテナントID | Azure認証用 |

---

## 🚀 Step 3: ワンクリックデプロイ！

### 3-1. インフラ構築

1. **自分のリポジトリ** の「Actions」タブをクリック
2. 左メニューから「terraform-apply」を選択
3. 「Run workflow」ボタンをクリック
4. 「Run workflow」を再度クリック
5. ⏳ **約5分待機**（緑のチェックマークが付くまで）

### 3-2. Webサイトデプロイ

1. 「Actions」タブで「app-deploy」を選択
2. 「Run workflow」ボタンをクリック
3. 「Run workflow」を再度クリック
4. ⏳ **約2分待機**（緑のチェックマークが付くまで）

### 3-3. 完成！

1. 「app-deploy」のログを開く
2. 最後の方に表示される **Website URL** をクリック
3. 🎉 **あなたのWebサイトが公開されました！**

**例**: https://cloudappdevXXXXXX.z11.web.core.windows.net/

---

## 🗑️ Step 4: 削除（不要になったら）

### 方法1: GitHub Actions（推奨）

1. 「Actions」タブで「terraform-destroy」を選択
2. 「Run workflow」ボタンをクリック
3. **重要**: `confirm_destroy` に `DESTROY` と入力
4. 「Run workflow」をクリック
5. ⏳ **約3分で完全削除**

### 方法2: 手動削除

1. [Azure Portal](https://portal.azure.com) にログイン
2. 「リソースグループ」を検索
3. `cloud-app-starter-rg` を選択
4. 「削除」ボタンをクリック
5. リソースグループ名を入力して確認

---

## 🔧 トラブルシューティング

### ❌ よくあるエラー

#### 「認証エラー」が出る
- **原因**: GitHubシークレットの設定ミス
- **解決**: Step 2-2を再確認、値を再入力

#### 「権限エラー」が出る
- **原因**: Azure権限設定不足
- **解決**: Step 1-2の権限設定を再確認

#### 「リソース作成エラー」
- **原因**: Azure無料枠の制限
- **解決**: 不要なリソースを削除してから再実行

### 🆘 困ったときは

1. **GitHub Actions のログを確認**
   - 「Actions」タブ → 失敗したワークフロー → 詳細ログ

2. **Azure Portal で状況確認**
   - リソースグループ `cloud-app-starter-rg` の状態

3. **完全リセット**
   ```
   1. Step 4で完全削除
   2. 5分待機
   3. Step 3から再実行
   ```

---

## 🎨 カスタマイズ（上級者向け）

### Webサイトの内容を変更

1. リポジトリの `app/index.html` を編集
2. 変更をコミット・プッシュ
3. 自動的にWebサイトが更新される

### デザインを変更

1. `app/styles.css` を編集
2. 色、フォント、レイアウトを自由に変更
3. プッシュすると自動反映

---

## 💰 料金について

### 無料枠内での利用
- **Azure Storage**: 月5GB無料
- **データ転送**: 月15GB無料
- **このプロジェクト**: 月数円程度

### 料金を抑えるコツ
1. 使わないときは削除（Step 4）
2. 必要なときだけデプロイ（Step 3）
3. Azure Cost Management で定期確認

---

## 🎉 次のステップ

### 学習リソース
- **HTML/CSS**: [MDN Web Docs](https://developer.mozilla.org/ja/)
- **Azure**: [Microsoft Learn](https://docs.microsoft.com/ja-jp/learn/)
- **Terraform**: [公式チュートリアル](https://learn.hashicorp.com/terraform)

### 発展的な使い方
- カスタムドメインの設定
- HTTPS証明書の追加
- データベース連携
- 複数環境の管理

---

## ✅ チェックリスト

### 初回セットアップ
- [ ] GitHubアカウント作成
- [ ] Azureアカウント作成
- [ ] Service Principal作成
- [ ] 認証情報取得・保存
- [ ] リポジトリフォーク
- [ ] GitHubシークレット設定

### デプロイ
- [ ] terraform-apply実行
- [ ] app-deploy実行
- [ ] WebサイトURL確認
- [ ] サイト動作確認

### 削除（必要時）
- [ ] terraform-destroy実行
- [ ] Azure Portal確認
- [ ] 課金停止確認

---

**🎊 おめでとうございます！** 
あなたは今、クラウドインフラを自在に操れるようになりました！