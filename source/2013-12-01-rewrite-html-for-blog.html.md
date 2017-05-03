---
title: ブログのHTMLを全面的に書き直した
date: 2013-12-01
tags: Blog
---

ヘッダーとフッターを除いたコンテンツを`main`タグで括ってみたり、RSSで配信される内容は`article`タグにしたり、投稿日を`time`タグに置き換えたりした。`aside`と`section`どちらを使用しようか迷ったところもあったけど、`article`で括った内容に関連する付加要素を`aside`にして、右下に出てる簡易プロフィールは`section`にしておいた。多分問題ないだろう。

今までPureという軽量CSSフレームワークを利用していたのだけど、一部要素にグリッド機能を使っていた程度だったので今回から外すことにした。この手のツールはどうしても余計な`div`タグが増えてしまうのが悩みどころ。便利なんだけどね。

そういう意味では[semantic-ui](http://semantic-ui.com/)はとても良さそうにみえる。