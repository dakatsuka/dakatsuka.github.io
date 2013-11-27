---
title: Rails4 + RSpec + Guard + SpringでDEPRECATION WARNINGが出たので対処した
date: 2013-11-27
tags: Ruby, Rails, BDD
---

ちょっと前までのRailsのテスト環境といえば、RSpec + Guardという構成が定番だったように思う。最近はこれにSpringを加えるのが流行のようだ。<small>（しかし、わずか半年ほどPHPという魔境に囚われていただけで、Railsはメジャーバージョンが上がっているし関連ライブラリに新顔も出てるし怖い怖い）</small>

そこそこ時間も出来たので、[こちらの記事を参考](http://lab.heathrow.co.jp/2013/09/17/3421)にして、作りかけて放置していたRailsアプリにSpringを組み込んでみたら、動くには動くのだけどDEPRECATION WARNINGが出てしまった。

```
22:16:29 - WARN - Guard::RSpec DEPRECATION WARNING: The :spring option is deprecated. Please customize the new :cmd option
to fit your need.
```

調べてみるとGuardfileの書き方が少し変わったらしい。spring-commands-rspecというgemを追加して1行修正するだけ。

```diff
-guard :rspec, spring: true do
+guard :rspec, cmd: 'spring rspec' do
```
