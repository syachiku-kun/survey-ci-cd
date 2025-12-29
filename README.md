# survey-ci-cd

GitLab+Git Runner をオンプレミス版で構築して動作を試してみるまでの道のり

# やりたいこと

- オンプレミス版 GitLab で Merge Request をした時に、「コード判別用の commitSHA 刻印+LLM によるコードレビュー + ビルド + デプロイ」をするパイプラインを実行させたい。

# ロードマップ

- 必要なものリストと要件・補足

1. GitLab

- コード管理をする git を基盤とした web アプリ
- Hyper-V にインストールした Linux ディストリビューションを使う(SaaS ではない)
- 環境を分ける＆構築を楽にするために Docker コンテナで構築する
- GitLab と Git Runner とは別アプリ

2. Git Runner

- コード管理をする git を基盤とした web アプリ
- Hyper-V にインストールした Linux ディストリビューションを使う(SaaS ではない)
- 環境を分ける＆構築を楽にするために Docker コンテナで構築する
- GitLab と Git Runner とは別アプリ

3. Runner 実行環境(windows)
4. Runner 実行環境(linux)

## 1. Hyper-Vで環境構築

- [こっちに記載](01-setup-vm/Readme.md)
