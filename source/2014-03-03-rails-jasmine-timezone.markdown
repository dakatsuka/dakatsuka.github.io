---
title: Rails + Jasmineでテスト実行時のタイムゾーンを変更する
date: 2014-03-03
tags: Ruby,Rails,JavaScript
---

あまりタイムゾーンに依存するテストって宜しくないと思いますが。。。とはいえ特定のタイムゾーンで固定しておきたい事もあるので調べてみた。

[PhantomJSのIssue](https://github.com/ariya/phantomjs/issues/10379)をみると、TZという環境変数を設定することでタイムゾーンを変更出来るようなので  `spec/javascripts/support/jasmine_helper.rb` に下記コードを追加する。

```ruby
ENV["TZ"] = "UTC"
```

これで `rake jasmine:ci` 実行時は常にUTCになる。
