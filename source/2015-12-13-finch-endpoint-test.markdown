---
title: FinchのEndpointのテスト方法を調べた
date: 2015-12-13
tags: Scala, Finch, Finagle
---

Finchはエンドポイントを作るときに戻り値を型で縛れるので、正常系のレスポンスに関してはコンパイラを信用して大丈夫だろう。ただし、ステータスコードまでは検証出来ないので、リクエストパラメータによってステータスコードが変わる場合などはしっかりとテストを書いておきたい。

FinchのEndpoint型はtoService関数で`com.twitter.finagle.Service`型に変わり、これにRequestを渡せばResponse型が返ってくるらしい。REPLで確認してみた。

```
scala> import io.finch._
import io.finch._

scala> import com.twitter.finagle.http._
import com.twitter.finagle.http._

scala> import com.twitter.util.Await
import com.twitter.util.Await

scala> val endpoint: Endpoint[String] = get("foo" / string) { s: String => Ok(s) }
endpoint: io.finch.Endpoint[String] = GET /foo/:string

scala> val service = endpoint.toService
service: com.twitter.finagle.Service[com.twitter.finagle.http.Request,com.twitter.finagle.http.Response] = <function1>

scala> service(Request("/foo/bar"))
res0: com.twitter.util.Future[com.twitter.finagle.http.Response] = Promise@886121853(state=Done(Return(Response("HTTP/1.1 Status(200)"))))

scala> val response = Await.result(service(Request("/foo/bar")))
response: com.twitter.finagle.http.Response = Response("HTTP/1.1 Status(200)")

scala> response.status
res1: com.twitter.finagle.http.Status = Status(200)

scala> response.contentString
res2: String = bar
```

ちゃんと返ってきた。問題なさそう。

### 参考文献
* [finch/EndToEndSpec.scala · finagle/finch](https://github.com/finagle/finch/blob/4bf3de4/core/src/test/scala/io/finch/EndToEndSpec.scala)
