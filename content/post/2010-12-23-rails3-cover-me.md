---
title: Rails3 + cover_me でテストカバレッジ
slug: rails3-cover-me
date: 2010-12-23
tags: [Ruby, Rails]
---

Ruby 1.9 + Rails3 で rcov がうまく動かなかったので cover_me というカバレッジツールを使ってみる事にしました。

Gemfileに下記行を追加して、

```ruby
gem "cover_me"
```

下記コマンドでインストールします。

```sh
$ bundle install
$ rails g cover_me:install
```

あとはいつも通りrake specを実行すれば、自動でcoverageディレクトリが作成されその中にカバレッジ結果が格納されます（HTML形式）。

お手軽です！

ちなみにMacではテスト終了後自動でブラウザが起動してHTMLを表示してくれましたが、Ubuntuではエラーが出たため、下記コードをlib/tasks/cover_me.rakeの先頭に追加して自動でブラウザが起動しないようにしました。

```ruby
CoverMe.config do |c|
  c.at_exit = Proc.new {}
end
```
