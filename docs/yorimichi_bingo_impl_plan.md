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
- [x] `bingo_cards` migration 作成＆migrate
- [x] `BingoCard` model 作成（token生成、validations、expired?）
- [x] token unique制約で衝突回避（衝突時は再生成）

**完了条件**
- Rails consoleで `BingoCard.create!` が成功し、tokenが8文字で付与される

---

### M1: 入口（作成画面）
**作業**
- [x] routes: `GET/POST /yorimichi`
- [x] `start` アクションとフォーム表示（title, duration_days）
- [x] `create` でカード生成→ `redirect_to /yorimichi/:token`

**完了条件**
- ブラウザで `/yorimichi` →「はじめる」でカード作成できる

---

### M2: カード表示（静的）
**作業**
- [x] routes: `GET /yorimichi/:token`
- [x] `show` でカードを取得して 5x5 を表示
- [x] status（期限残日数、達成数、ビンゴ数）表示

**完了条件**
- token URLを直打ちして、同じカードが表示される

---

### M3: トグル（Hotwire）
**作業**
- [x] routes: `PATCH /yorimichi/:token/toggle`
- [x] `toggle` アクション（serviceでトグル）
- [x] Turbo Streamで `cell_#{id}` と `bingo_status` を差し替え

**完了条件**
- クリック即時反映（リロード不要）
- セルとステータスだけが更新される

---

### M4: 期限ロック
**作業**
- [x] `expired?` true の場合、UIでボタン非表示/無効化
- [x] `toggle` でも更新拒否（flashメッセージ等）
- [x] `expires_at` 表示（残日数）

**完了条件**
- expires_atを過去にして、更新できないことを確認

---

### M5: 新カード発行（reset）
**作業**
- [x] routes: `POST /yorimichi/:token/reset`
- [x] 旧カードのtitleを引き継いで新カード生成（新token）
- [x] confirm ダイアログ
- [x] 旧カードは残す

**完了条件**
- 「あたらしいびんごを作る」で新URLに移動し、盤面が初期化されている

---

### M6: 最低限の体験調整（仕上げ）
**作業**
- [x] 共有URLの表示（コピーしやすく）
- [x] 見た目（余白/枠/押しやすさ）を最低限整える
- [x] 文言（子ども向け）調整

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
- 一覧画面（カード履歴）
- Rack::Attackで総当たり対策

---

## 12. ポストMVPロードマップ（案）
MVP後に段階的に足すなら、以下のPシリーズを上から順に進めると安全。

### P1: カテゴリ選択 + DBテンプレ同期
**目的**: start画面は「スタート」ボタンだけに留め、遷移先の初回 edit 画面でカテゴリを3〜8個選ぶと25マスが自動で埋まる体験を作る。
**作業例**
- schema拡張: `bingo_categories`（display_name, slug）と `bingo_items`（category_id, title, description, illustration）を追加し、カテゴリ別の候補マスをDB管理（descriptionはedit画面や「使用例」ページでtipsとして表示）。
- seedsまたは`db/templates/*.yml`からカテゴリ／アイテムをまとめてインポートする rake task を用意（後日「使用例」ページで再利用できるようにする）。
- `start`画面はシンプルな説明 + スタートボタンのみとし、ボタン押下後の `edit`（初回のみアクセス可能）でカテゴリ選択UI（3〜8個のチェックボックス）を表示。
- `BoardBuilder` を拡張し、選択されたカテゴリに属するアイテムをランダム or 均等に25マスへ割り当てる。例：「しぜん」「おみせ」「まち」を選択すると、それぞれのカテゴリから交互にマスが埋まる。
- カテゴリを選び直すとプレビューをリフレッシュし、その場で盤面が入れ替わる。保存後は従来どおり `show` で共有。
**完了条件**
- `/yorimichi` → スタート → 初回 edit でカテゴリを3〜8個選ぶだけで25マスが生成される。
- Rake task でカテゴリ/アイテムを再投入しても既存カードは影響を受けない。

### P2: タイトル + 説明 + モーダル情報
**目的**: ビンゴの趣旨やルールを共有しやすくする。
**作業例**
- `bingo_cards` に `description`（text）と `how_to_play`（jsonb or text, 任意）を追加。
- 作成フォームに説明入力欄を追加し、`show` ではタイトル横に「i」ボタンを置いて Stimulus でモーダルを表示。モーダルには説明文 + カテゴリ情報を載せる。
- トグルできない状態（期限切れ・閲覧専用）もモーダル内に表示して混乱を避ける。
**完了条件**
- タイトル下の説明リンクでモーダルが開き、概要/カテゴリ/遊び方を参照できる。
- description が空の場合は UI が余計な隙間を作らない。

### P3: セルUI（ボタン化 + イラスト）
**目的**: 子どもでも直感的に押せるように、セル全体をボタン化し、簡単なアイコン/イラストを添える。
**作業例**
- `_cell.html.erb` を `<button>` ベースに書き換え、アクセシビリティ属性（`aria-pressed` 等）を付与。
- items の各要素に `illustration`（例: `emoji`, `asset_name`, `color`）を持たせ、`BoardBuilder` とテンプレ data がそれを供給。
- asset pipeline or CDN（app/assets/images/features/yorimichi/）にシンプルなSVGを配置し、遅延読み込みで描画。
- 押下アニメーション（scale, shadow）をCSSで追加。
**完了条件**
- すべてのセルがキーボードでも押せる `<button>` になり、イラスト付きで表示される。
- 既存カード（イラストなし）も壊れず、フォールバックテキストで表示。

### P4: 達成演出 + ビンゴ計測API化
**目的**: ビンゴ成立時の盛り上げと、将来的な分析API互換を意識。
**作業例**
- `BingoChecker` の結果に「新しく成立したライン数」を返すよう変更し、Turbo Stream で Stimulus controller にイベントを投げる。
- Stimulus側で confetti / fireworks アニメーション（Canvas または CSS）を再生し、ダイアログでメッセージを表示。
- 連続ビンゴ時に過剰発火しないよう debounce を実装。
**完了条件**
- 新しいビンゴラインができた瞬間に演出が走り、既存ビンゴでは演出されない。
- アニメーションは非対応ブラウザでも gracefully degrade する。

### P5: カード履歴・一覧
**目的**: 過去のカードを振り返れるようにする。
**作業例**
- `GET /yorimichi/history`（または同等）で、token を保持するユーザーが自分のブラウザから履歴を見られる仕組みを追加（sessionに最近作成したtokenを保存）。
- 一覧にはタイトル/カテゴリ/期限/進捗サマリを表示し、クリックで `show` に遷移。
- 将来的なユーザーアカウント導入に備え、controller/serviceを疎結合に作る。
**完了条件**
- MVP後に作った複数カードが履歴ページで確認できる。
- セッションが無い場合はシンプルな空表示 + 説明。

### P6: Rate Limiting（Rack::Attack）
**目的**: token 総当たりや高頻度トグルを抑止。
**作業例**
- `/yorimichi/:token` の連続アクセス、`toggle` のPOST頻度、`POST /yorimichi` のカード作成をそれぞれ制限するルールを追加。
- 429応答時には簡単なJSON/Turbo Stream文言を返し、UIでリトライ案内。
**完了条件**
- 意図的な連打で 429 が返ること、通常利用では引っかからないことを確認。


以上
