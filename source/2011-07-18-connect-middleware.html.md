---
title: connect middlewareでexpressを拡張しよう
date: 2011-07-18
tags: Node.js
---

connect (express) は Ruby の Rack と同じようにミドルウェアを使うことで簡単に拡張する事が出来ます。このミドルウェアの使い方・作り方を知っているだけで express での開発が相当楽になりますので覚えておいて損は無いでしょう。

## ミドルウェアを使う

ミドルウェアを express に組み込むには use メソッドを使います。つまり、普段よく使う bodyParser や cookieParser, logger なども実は connect のミドルウェアです。

```javascript
var express = require('express')
var app = express.createServer();
 
app.configure(function() {
  app.use(app.logger());
  app.use(app.bodyParser());
  app.use(app.cookieParser());
});
```

公式で用意されているミドルウェアとその使い方は [Connect – middleware framework for nodejs](http://senchalabs.github.com/connect/) をご覧ください。また、[サードパーティ製のミドルウェア](https://github.com/senchalabs/connect/wiki)も最近充実してきました。チェックしておくと良いでしょう。

## ミドルウェアを自作する

connectのミドルウェアは簡単に自作することが出来ます。試しに、アクセスがあるたびにコンソールにHTTPのリクエストヘッダを出力するミドルウェアを作ってみます。

middleware.js に下記コードを記述します。

```javascript
var requestHeader = function() {
  return function(req, res, next) {
    console.log(req.headers);
    next();
  };
};
 
exports.requestHeader = requestHeader;
```

同一ディレクトリに app.js を作成し、下記コードを記述します。

```javascript
var express = require('express')
  , middleware = require('./middleware')
  , app = express.createServer();
 
app.configure(function() {
  app.use(middleware.requestHeader());
});
 
app.get('/', function(req, res) {
  res.send("Hello World");
});
 
app.listen(3000);
```

node app.js でサーバを立ち上げ、 http://localhost:3000/ にブラウザで実際にアクセスしてみましょう。コンソールにUserAgentなどの情報が出力されるはずです。

## まとめ

上でHTTPヘッダを出力する実用性皆無なミドルウェアを作成しましたが、コードは非常にシンプルで分かりやすいと思います。『req / res 引数でデータを取得する事ができ、適宜 req / res に対し改変・追加などを行い、next(); で次のミドルウェアに処理を渡す』 この動きを抑えておけば大丈夫です。

UserAgentで処理を振り分けやモバイル端末の検出、認証処理などはミドルウェアとして実装する事で、他プロジェクトでの使い回しもでき、且つコードの見通しも良くなるのでおすすめです。
