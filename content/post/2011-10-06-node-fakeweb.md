---
title: Node.jsで使えるHTTP偽装モジュール node-fakeweb
slug: node-fakeweb
date: 2011-10-06
tags: [Node.js]
---
主に外部のAPIが絡んでくるアプリのテストに使えるモジュールです。Node.jsの標準モジュールであるhttpではなく、requestというモジュール経由のHTTPアクセスを乗っ取ってレスポンスを偽装します。

* [ctide/fakeweb – GitHub](https://github.com/ctide/fakeweb)

npmで入れることが出来ます。

```
npm install request node-fakeweb
```

使い方は下記のようにします。

```javascript
var request = require('request');
var fakeweb = require('node-fakeweb');
 
fakeweb.allowNetConnect = false;
fakeweb.registerUri({
  uri: "http://www.google.co.jp:80/",
  statusCode: 200,
  body: "Hello World!"
});
 
request.get({uri: "http://www.google.co.jp:80/"}, function(err, response, body) {
  console.log("StatusCode:" + response.statusCode);
  console.log("Body:" + body);
});
```

実行してみると

```
$ node test.js
StatusCode:200
Body:Hello World!
```

ちゃんとレスポンスが偽装されていますね。私はVowsと組み合わせて使っています。
