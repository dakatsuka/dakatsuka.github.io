---
title: node.js で コマンドライン引数を取るには
slug: nodejs-opts
date: 2011-06-18
tags: [Node.js]
---

node.js でコマンドライン引数を取りたい場合は opts というモジュールを使うことで簡単に実現出来ます。

optsモジュールは npm でインストールします。

```sh
npm install opts
```

試しに引数で指定したポート番号でHTTPサーバを立ち上げるコードを書いてみました。

```javascript
var http = require('http')
  , opts = require('opts');
 
opts.parse([
    {
        'short': 'p',
        'long': 'port',
        'description': 'HTTP port',
        'value': true,
        'required': false
    },
]);
 
var port = opts.get('port') || 3000
 
server = http.createServer(function(req, res) {
    res.writeHead(200, {'Content-Type': 'text/html'});
    res.write('&lt;h1&gt;Hello World!&lt;/h1&gt;');
    res.end();
});
 
server.listen(port);
```

実行。

```sh
node app.js -p 3001
```

requiredをtrueにして引数を省略して起動するとちゃんとエラーになります。

```sh
$ node app.js 
Missing required option: p
 
Usage: node /path/app.js [options]
HTTP port
    -p, --port <value> (required)
```
