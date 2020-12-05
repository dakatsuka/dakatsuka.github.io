---
title: Ruby 1.9.2 + Rails3でテストカバレッジを取るにはSimpleCovが良さそう
slug: simplecov
date: 2011-10-20
tags: [Ruby, Rails]
---

Ruby (Rails) でテストカバレッジといえば Rcov ですね。

しかし Rcov は Ruby 1.9.x に非対応なので Ruby 1.9.2 + Rails3 な環境で開発をしている方は [SimpleCov](https://github.com/colszowka/simplecov) を使うと幸せになれます。名前にSimpleと付いていますが高機能で見た目も綺麗です。また [simplecov-rcov](https://github.com/fguillen/simplecov-rcov) を併用すれば Rcov のフォーマットで出力することも出来るので、Jenkins などのCIツールとの連携も難しくないはずです。

* [colszowka/simplecov – GitHub](https://github.com/colszowka/simplecov)
* [fguillen/simplecov-rcov – GitHub](https://github.com/fguillen/simplecov-rcov)

## 使い方

Gemfileに下記コードを追加してbundle installします。

```ruby
group :test do
  gem "simplecov", :require => false
end
```

spec/spec\_helper.rb の最上位に下記コードを追記します。

```ruby
require 'simplecov'
SimpleCov.start 'rails'
```

準備完了。rake specを実行すれば coverage ディレクトリの中に結果が生成されています。

## そういえば

以前 [cover\_me](https://github.com/markbates/cover_me) の[紹介記事](/2010/12/23/rails3_cover_me.html)を書いた事を今更思い出しました。こちらのライブラリも引き続き開発が続けられているようです。
