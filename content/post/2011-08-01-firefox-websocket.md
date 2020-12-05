---
title: Firefox Nightly, Aurora で WebSocket を使うには
slug: firefox-websocket
date: 2011-08-01
tags: [Node.js]
---

Google Chromeのノリで new WebSocket() としても全く動く気配が無く、ググってもあまり情報が出てこなかったので、地味に手こずりました。

FirefoxのNightly版、Aurora版でWebSocketを使用する場合はプレフィックスを付ける必要があるようです。

```javascript
var ws = new MozWebSocket("ws://xxxxx");
```

これで動きました。
