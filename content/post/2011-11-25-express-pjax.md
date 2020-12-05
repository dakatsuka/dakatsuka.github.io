---
title: Express + jQueryでpjaxを使う
slug: express-pjax
date: 2011-11-25
tags: [Node.js]
---

先日、暇つぶしに Express で噂の pjax を使って遊んでみました。pjax 自体は jquery-pjax を使う事で手間をかけずに実現出来ますね。サーバ側もHTTPリクエストヘッダにX-PJAXがあるかどうか判定し、あった場合は`layout: false`とするだけなのでとても簡単です。

app.js のコードはこんな感じに。

```javascript
app.get('/', function(req, res) {
  if (req.header['X-PJAX']) {
    res.render('index', { layout: false });
  } else {
    res.render('index');
  }
});
```

しかし毎回if文を書くのも面倒なので、pjaxなリクエストが来た時だけlayout: falseになるようにrenderメソッドをラップした新しいメソッドを作成しました。npmでインストール出来ます。

```
npm install express-pjax
```

使い方：

```javascript
var express = require('express');
var pjax    = require('express-pjax');
var app     = express.createServer();
 
app.configure(function() {
  app.use(pjax());
});
 
app.get('/', function(req, res) {
  res.renderPjax('index', { locals: { hello: "Hello World!" } });
});
```

本当はrender自体をカスタマイズしたかったのですが、Expressのソースを見た限りではちょっと難しそうだったので新たにrenderPjaxというメソッドを作りました。そのうちリダイレクトにも対応したいですね。

* [dakatsuka/express-pjax – GitHub](https://github.com/dakatsuka/express-pjax)
