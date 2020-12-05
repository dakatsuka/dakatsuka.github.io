---
title: Middlemanでビルド時にだけ特定の要素を出力したい場合
slug: middleman-build-helper
date: 2013-11-24
tags: [Middleman]
---

Livereload環境では特に出力しなくても良いもの、または出力されるとマズいものがあったりする。例えばソーシャルサービス系のシェアボタンやGoogle Analyticsのトラッキングコードなど。

テンプレート内では[Middleman::Application](http://rubydoc.info/github/middleman/middleman/Middleman/Application)のメソッドが使えるようなので`build?`メソッドを利用する。

```haml
- if build?
    :javascript
      /** Google Analytics Tracking code */
```

確認してないけど`development?`は逆の動きをしそう。
