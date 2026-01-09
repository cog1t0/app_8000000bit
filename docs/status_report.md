# 開発状況サマリ（現状把握）

## プロジェクト概要
- Rails 8.0 系のアプリケーションで、Propshaft・Importmap・Tailwind CSS など標準的なモダン構成を採用しています。【F:Gemfile†L1-L38】【F:app/views/layouts/application.html.erb†L4-L28】
- ルーティングは大きく 2 系統で、訪問記念ページ(`/app`)と占い診断フロー(RabbitHole)を提供しています。【F:config/routes.rb†L1-L8】

## 主要機能
### `/app` 訪問記念ページ
- 初回アクセス日時・位置情報・逆ジオコーディングした住所をローカルストレージへ保存し、再訪時に読み出して表示します。【F:app/views/app/index.html.erb†L6-L167】
- 位置情報取得は一度のみ記録する仕様で、取得済みの場合はボタンを隠してステータスメッセージを表示します。【F:app/views/app/index.html.erb†L52-L136】
- 住所変換には OpenStreetMap Nominatim API を利用しており、取得結果をローカルストレージへキャッシュします。【F:app/views/app/index.html.erb†L86-L133】

### RabbitHole 診断フロー
- 画面遷移は入力フォーム→診断生成→作成完了画面→結果閲覧/コード入力という流れで構成されています。【F:config/routes.rb†L4-L8】【F:app/views/rabbit_hole/form.html.erb†L1-L60】【F:app/views/rabbit_hole/created.html.erb†L1-L10】【F:app/views/rabbit_hole/show.html.erb†L1-L116】【F:app/views/rabbit_hole/enter_code.html.erb†L1-L15】
- `RabbitHoleController#create` でフォーム値を受け取り、命式データ取得→AI 診断→結果保存→セッションへトークン保管→リダイレクトまでを実行します。【F:app/controllers/rabbit_hole_controller.rb†L8-L47】
- 診断結果は 5 分間の閲覧制限があり、期限切れ後はセッションに保存されたトークンが一致する場合か、4 桁コードによる最新結果照会のみ閲覧可能です。【F:app/controllers/rabbit_hole_controller.rb†L69-L118】
- 4 桁コード入力画面では有効期限や入力エラーを表示する仕組みが組み込まれています。【F:app/controllers/rabbit_hole_controller.rb†L83-L101】【F:app/views/rabbit_hole/enter_code.html.erb†L1-L15】
- フォーム画面は Basic 認証で保護されますが、コントローラーの資格情報(`riku`/`riku1031`)と画面の案内文(`taro`/`taro123`)が食い違っています。【F:app/controllers/rabbit_hole_controller.rb†L2-L6】【F:app/controllers/rabbit_hole_controller.rb†L127-L133】【F:app/views/rabbit_hole/form.html.erb†L55-L58】
- 作成完了画面ではトークン URL と 4 桁コード、有効期限を提示します。【F:app/views/rabbit_hole/created.html.erb†L1-L9】
- 結果表示画面は命式の主要項目をカード表示し、通変星・十二運勢のアイコン表示ヘルパーにも対応しています。【F:app/views/rabbit_hole/show.html.erb†L11-L115】【F:app/helpers/icon_helper.rb†L1-L70】
- 期限切れ案内用の `expired.html.erb` も用意されていますが、現時点ではコントローラーから呼び出されていません。【F:app/views/rabbit_hole/expired.html.erb†L1-L45】【F:app/controllers/rabbit_hole_controller.rb†L69-L123】

## ドメインモデル
- `MeishikiMaster` は生年月日＋性別の組み合わせを一意制約で管理し、診断結果と 1:N で紐付きます。【F:app/models/meishiki_master.rb†L1-L6】【F:db/schema.rb†L26-L53】
- `DiagnosisResult` は命式マスターへ外部キーで結びつき、トークンの存在性・一意性を検証します。【F:app/models/diagnosis_result.rb†L1-L6】【F:db/schema.rb†L6-L24】

## 外部サービス連携
- `MeishikiFetcher` が `chi92.suinavi.com` へ POST し、取得した HTML を Nokogiri または正規表現でパースして命式データを生成します。【F:app/services/meishiki_fetcher.rb†L254-L417】【F:app/services/meishiki_fetcher.rb†L421-L479】
- SSL 検証のために `config/certs` 以下へ中間証明書を同梱し、環境変数 `SSL_CA_FILE` や `MEISHIKI_FETCHER_INSECURE` で挙動を切り替えられるようになっています。【F:app/services/meishiki_fetcher.rb†L293-L350】【F:config/certs/README.md†L1-L25】

## AI 診断ロジック
- `DiagnosisAiService` は現状ダミー実装で、命式情報を文字列に織り込んだサマリとアドバイスを生成するだけです（外部 API 連携なし）。【F:app/services/diagnosis_ai_service.rb†L1-L40】

## テスト状況
- コントローラテストは `/app` の表示確認のみ実装されており、RabbitHole 系は未整備です。【F:test/controllers/app_controller_test.rb†L1-L8】【F:test/controllers/rabbit_hole_controller_test.rb†L1-L7】
- モデルテスト・フィクスチャも雛形のままで、`diagnosis_results.yml` では `fortune_type` が空欄になっています。【F:test/models/meishiki_master_test.rb†L1-L7】【F:test/models/diagnosis_result_test.rb†L1-L7】【F:test/fixtures/diagnosis_results.yml†L3-L19】

## 既知の課題・未実装ポイント
- RabbitHole フォームの Basic 認証案内と実際の資格情報が不一致のため、利用者がアクセスできない恐れがあります。【F:app/controllers/rabbit_hole_controller.rb†L127-L133】【F:app/views/rabbit_hole/form.html.erb†L55-L58】
- RabbitHole 関連のテスト（コントローラ、サービス、モデル）とフィクスチャ整備が未着手です。【F:test/controllers/rabbit_hole_controller_test.rb†L1-L7】【F:test/fixtures/diagnosis_results.yml†L3-L19】
- `DiagnosisAiService` はダミーのままなので、本番想定の AI API 連携やプロンプト設計が必要です。【F:app/services/diagnosis_ai_service.rb†L1-L40】
- アイコン表示用ヘルパーは `tsuhen/*.svg` と `unsei/*.svg` を参照するため、対応する SVG を `app/assets/images` 配下へ用意する必要があります。【F:app/helpers/icon_helper.rb†L1-L70】
- `expired.html.erb` の表示条件やルーティングが未結線のため、閲覧期限切れ時の動線を要検討です。【F:app/views/rabbit_hole/expired.html.erb†L1-L45】【F:app/controllers/rabbit_hole_controller.rb†L69-L123】

