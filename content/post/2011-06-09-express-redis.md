---
title: node.js + express でセッションストアを Redis に変更する方法
slug: express-redis
date: 2011-06-09
tags: [Node.js]
---

express のセッションは標準だとメモリストアなので、再起動するたびにセッションが消えてしまいます。そこでセッションストアを Redis にしてセッションを永続化出来るようにしてみます。

下記環境で動作を確認しました。

* Node.js v0.4.8
* express v2.3.11
* connect-redis v1.0.5

npm で connect-redis をインストールします。

```sh
npm install connect-redis
```

app.js を次のように書き換えます。

```javascript
var express = require('express');
var RedisStore = require('connect-redis')(express);
var app = express.createServer();
 
app.use(express.cookieParser());
app.use(express.session({
    secret: "secret key",
    store: new RedisStore(),
    cookie: { maxAge: 86400 * 1000 }
}));
```

maxAge でセッション（クッキー）の有効期限を指定する事が出来ます。cookie: 自体を省略するとデフォルトは4時間のようです。指定したい場合は上記のようにミリ秒で指定する事が出来ます。
