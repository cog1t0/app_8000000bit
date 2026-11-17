# 慧己ちゃんのホームページ・かるた

- `/emi`: 紹介ページ（認証なし、検索除外）。専用レイアウト/CSS。
- `/emi/karuta`: Basic認証付きゲーム。ひとり練習/CPU対戦、46枚、録音済み音声の再生。
- `/emi/karuta/files/:name`: 同じBasic認証を必須にした許可リスト式配信。
- 外部API・APIキー・新しいgemは不要。対戦はブラウザ内のタイマーとゲームロジック。

## 非公開データ

このリポジトリは公開されているため、絵札・読み札・音声はコミットしない。
`storage/emi_karuta/` に以下の3ファイルを配置する（storageはGit管理対象外）：

- `topics.js`：読み札
- `card-images.js`：埋め込み絵札
- `reading-audio.js`：埋め込み音声

元のemiプロジェクトの `karuta/dist/` にある同名ファイルからコピーする。
画像/音声はdata URLとしてこの認証済み配信に含まれ、publicやアセットパイプラインには置かない。
現時点では従来の合成済み音声。本人の録音を受領したら音声バンドルを固定差し替えする。ゲーム内に録音・音声変更UIは追加しない。

## 認証・運用

`EMI_KARUTA_USERNAME` と `EMI_KARUTA_PASSWORD` を環境変数で設定する。これはBasic認証用でありAPIキーではない。
どちらか未設定なら503。設定済みで未認証/不正な認証なら401。全配信をno-storeにする。
パスワードをコード、URL、Gitに記録しない。本番はHTTPS必須（既存Railsのforce_ssl設定を維持）。
Basic認証によりブラウザのログイン画面が出る。専用ログアウトはなく、共有端末では利用後にブラウザを閉じる。
認証済みの利用者による保存や転載は防げない。

本番の永続storageボリュームにも3ファイルの配置が必要。デプロイや秘密情報の設定はまだ行っていない。
本番公開前に町内会用の認証情報を決め、非公開データを配置する。

## 確認

`bin/rails test test/integration/emi_karuta_test.rb`
`node test/javascript/emi_karuta_match_test.cjs`

認証テストは一時的なダミーデータを使い、実際の札/音声や秘密情報は不要。
