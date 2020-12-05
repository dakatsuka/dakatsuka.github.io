---
title: http4sでHTTPSを有効にする
slug: http4s-with-ssl
date: 2015-11-22
tags: [Scala, http4s]
---

SSLSupportパッケージをインポートしてBlazeBuilderの`.withSSL`にKeyStoreの情報を渡せばHTTPSが有効になる。代わりにHTTPは無効になってしまうので注意。

```scala
import org.http4s.server.blaze.BlazeBuilder
import org.http4s.server.SSLSupport._

BlazeBuilder
  .bindHttp(8080)
  .withSSL(
    keyStore = StoreInfo("/path/to/keystore", "password"),
    keyManagerPassword = "password"
  )
  .mountService(servie)
  .run
  .awaitShutdown()
```

OpenSSLで生成した鍵や証明書からKeyStoreファイルを作る方法、毎回ググってる気がするのでメモっておく。

```
$ openssl pkcs12 -inkey server.key -in server.crt -export -out server.pkcs12
$ keytool -importkeystore -srckeystore ./server.pkcs12 -srcstoretype PKCS12 -destkeystore server.keystore
$ keytool -keystore ./server.keystore -import -alias ServerChain -file ./server.ca -trustcacerts
```

ちなみにBlazeBuilderで`.enableHttp2(true)`を書けばHTTP/2が有効になるらしいが、手元ではうまく動かなかった。なにか設定が足りないのかもしれない。。。
