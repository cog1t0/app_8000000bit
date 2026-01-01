# よりみちびんご 実装計画書（Rails + Hotwire / 共有トークン方式）
作成日: 2026-01-01  
対象: 既存Railsアプリに“相乗り”で追加する機能（名前空間で隔離）

---

## 1. 目的
「いつもの毎日に、ひとつ寄り道を。」をコンセプトに、期限付きのビンゴカードを作成・共有し、家族/友人で進捗を共有しながら達成を楽しめるWebアプリをRails + Hotwireで実装する。

---

## 2. MVPスコープ（今回やること / やらないこと）

### 2.1 今回やること（MVP）
- 入口 `/yorimichi` でカード作成（タイトル・期限日数）
- カードURL `/yorimichi/:token` を共有して、同じ進捗を閲覧・更新
- 5x5（25マス）ビンゴ、Freeなし
- マスの達成/未達成トグル（Hotwireでセル＆ステータスだけ更新）
- 期限（expires_at）を過ぎたら「閲覧のみ・更新不可」
- 「あたらしいびんごを作る」＝新カード発行（新token）、旧カードは残す

### 2.2 今回やらないこと（後回し）
- GPS / AR / 写真証明
- ユーザーアカウント、ログイン、誰が押したか
- ランキング、通知、分析、複数カード一覧
- 難易度・カテゴリの高度な出し分け（MVPは固定25マスでOK）

---

## 3. 完成条件（受け入れ基準 / Done の定義）
以下を満たせばMVP完成：

1) **作成**
- `/yorimichi` で「はじめる」を押すとカードが作成され、`/yorimichi/:token` に遷移できる

2) **共有**
- `token` URLを別ブラウザ/別端末で開いても **同じカード状態（DB永続）** が見える

3) **操作**
- マスを押すと **ページリロード無し** に、該当セルとステータス（達成数/ビンゴ数）が更新される

4) **期限**
- `expires_at` 以降は閲覧はできるが **更新はできない**（UIもボタンが出ない or 押しても失敗する）

5) **再チャレンジ**
- 「あたらしいびんごを作る」で新カードが発行され、新tokenに遷移する（旧カードは残る）

---

## 4. URL設計（ユーザー体験優先）
- `GET  /yorimichi` : 入口（作成画面）
- `POST /yorimichi` : 作成 → `/yorimichi/:token` へリダイレクト
- `GET  /yorimichi/:token` : カード表示
- `PATCH /yorimichi/:token/toggle` : マストグル（Turbo Stream）
- `POST /yorimichi/:token/reset` : 新カード発行（新token）

---

## 5. データ設計（DB最小）

### 5.1 テーブル: `bingo_cards`
- `token` (string, unique, not null) : 英数字8文字（共有カードID）
- `title` (string, not null) : テーマ（例: いつもとちがう30日）
- `items` (jsonb, not null) : 25マス分の配列
- `expires_at` (datetime, not null) : 期限
- timestamps

### 5.2 items(JSON)フォーマット（例）
```json
[
  { "id": 1, "title": "パン屋でパンを買う", "checked": false, "checked_at": null },
  { "id": 2, "title": "行ったことないスーパーに行く", "checked": true, "checked_at": "2026-01-01T12:34:56+09:00" }
]
```

---

## 6. 実装アーキテクチャ（相乗り前提の隔離）

### 6.1 コントローラ
- `app/controllers/features/yorimichi_bingo_controller.rb`
  - `Features::YorimichiBingoController`（名前空間で既存コードへの影響を最小化）

### 6.2 サービス（ロジック隔離）
- `app/services/features/yorimichi_bingo/board_builder.rb` : 初期25マス生成、expires_at設定
- `app/services/features/yorimichi_bingo/toggler.rb` : 指定idのchecked反転、checked_at付与
- `app/services/features/yorimichi_bingo/bingo_checker.rb` : ビンゴ数、達成数計算

### 6.3 View（Hotwire前提）
- `app/views/features/yorimichi_bingo/start.html.erb`
- `app/views/features/yorimichi_bingo/show.html.erb`
- partial:
  - `_status.html.erb` : ステータス（期限/達成数/ビンゴ数）
  - `_grid.html.erb` : 5x5グリッド
  - `_cell.html.erb` : セル（Turbo Frame単位）
- turbo_stream:
  - `toggle.turbo_stream.erb` : cell + status の差し替え

---

## 7. セキュリティ/運用上の割り切り（MVP）
- トークンは「秘匿」ではなく「推測しにくい共有ID」
- 英数字8文字（大文字英字+数字）を推奨（数字8桁より耐性が高い）
- 総当たり対策はMVPでは必須にしない（必要なら `Rack::Attack` を後で追加）
- リセット誤操作対策：confirmダイアログで十分

---

## 8. マイルストーン（細かいゴール設定）
「上から順に潰す」前提。各マイルストーンは独立して検証可能。

### M0: DB・モデル基盤
**作業**
- [ ] `bingo_cards` migration 作成＆migrate
- [ ] `BingoCard` model 作成（token生成、validations、expired?）
- [ ] token unique制約で衝突回避（衝突時は再生成）

**完了条件**
- Rails consoleで `BingoCard.create!` が成功し、tokenが8文字で付与される

---

### M1: 入口（作成画面）
**作業**
- [ ] routes: `GET/POST /yorimichi`
- [ ] `start` アクションとフォーム表示（title, duration_days）
- [ ] `create` でカード生成→ `redirect_to /yorimichi/:token`

**完了条件**
- ブラウザで `/yorimichi` →「はじめる」でカード作成できる

---

### M2: カード表示（静的）
**作業**
- [ ] routes: `GET /yorimichi/:token`
- [ ] `show` でカードを取得して 5x5 を表示
- [ ] status（期限残日数、達成数、ビンゴ数）表示

**完了条件**
- token URLを直打ちして、同じカードが表示される

---

### M3: トグル（Hotwire）
**作業**
- [ ] routes: `PATCH /yorimichi/:token/toggle`
- [ ] `toggle` アクション（serviceでトグル）
- [ ] Turbo Streamで `cell_#{id}` と `bingo_status` を差し替え

**完了条件**
- クリック即時反映（リロード不要）
- セルとステータスだけが更新される

---

### M4: 期限ロック
**作業**
- [ ] `expired?` true の場合、UIでボタン非表示/無効化
- [ ] `toggle` でも更新拒否（flashメッセージ等）
- [ ] `expires_at` 表示（残日数）

**完了条件**
- expires_atを過去にして、更新できないことを確認

---

### M5: 新カード発行（reset）
**作業**
- [ ] routes: `POST /yorimichi/:token/reset`
- [ ] 旧カードのtitleを引き継いで新カード生成（新token）
- [ ] confirm ダイアログ
- [ ] 旧カードは残す

**完了条件**
- 「あたらしいびんごを作る」で新URLに移動し、盤面が初期化されている

---

### M6: 最低限の体験調整（仕上げ）
**作業**
- [ ] 共有URLの表示（コピーしやすく）
- [ ] 見た目（余白/枠/押しやすさ）を最低限整える
- [ ] 文言（子ども向け）調整

**完了条件**
- 家族/友人に見せて「分かる・押せる・楽しい」と言われる状態

---

## 9. テスト方針（MVP）
- 最低限：`BingoChecker` のユニットテスト（縦横斜め判定）
- UI/HotwireはMVPでは必須にしない（必要ならSystem Specを追加）

---

## 10. Codexに渡す作業指示テンプレ（順番が重要）
### 指示 1（M0）
- migration/model実装：token8文字、items(jsonb)、expires_at、validations、expired?

### 指示 2（M1）
- routesと `start/create`：`/yorimichi` 入口→作成→tokenへ

### 指示 3（M2）
- `show`：5x5表示、status表示

### 指示 4（M3）
- `toggle` + Turbo Stream：セル＆status差し替え

### 指示 5（M4）
- 期限ロック（UI + server）

### 指示 6（M5）
- `reset`：新カード発行、新tokenへ遷移

---

## 11. 追加アイデア（MVP後）
- カテゴリ（まち/こうえん/しぜん）でitemsを切り替え
- 達成演出（ビンゴ達成でメッセージ、紙吹雪）
- 共有の「閲覧のみ」リンク（readonly token）
- 一覧画面（カード履歴）
- Rack::Attackで総当たり対策

---

以上
