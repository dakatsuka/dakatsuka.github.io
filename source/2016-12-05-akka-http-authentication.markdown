---
title: Akka HTTPで認証機能を手軽に実装する方法
date: 2016-12-05
tags: Scala,Akka
---

これは[Scala Advent Calendar 2016](http://www.adventar.org/calendars/1492)の5日目です。埋まっていなかったので1日遅れでしれっと書くよ。

Akka HTTPには `AuthenticationDirective` という認証のためのディレクティブが標準で用意されていて、Bearer Token を自前で認証したいケースで使える。使いかたはコードを見たほうが分かりやすいと思うのでサンプルを乗せた。

```scala
import akka.actor.ActorSystem
import akka.http.scaladsl.Http
import akka.http.scaladsl.model.headers.{HttpChallenge, OAuth2BearerToken}
import akka.http.scaladsl.server.directives.{AuthenticationDirective, AuthenticationResult}
import akka.http.scaladsl.server.Directives._
import akka.stream.ActorMaterializer

import scala.concurrent.Future

case class Account(name: String)

object Main extends App {
  implicit val system = ActorSystem()
  implicit val materializer = ActorMaterializer()

  val route = pathEndOrSingleSlash {
    authenticate { account =>
      complete(account.name)
    }
  }

  Http().bindAndHandle(route, "", 8080)

  private def authenticate: AuthenticationDirective[Account] = {
    authenticateOrRejectWithChallenge[OAuth2BearerToken, Account] {
      case Some(OAuth2BearerToken(token)) if token == "123456789" =>
        Future.successful(AuthenticationResult.success(Account("user")))
      case _ =>
        Future.successful(AuthenticationResult.failWithChallenge(
          HttpChallenge("bearer", None, Map("error" -> "invalid_token")))
        )
    }
  }
}
```

`sbt run` して `curl` で動作確認をしてみる。正しいトークンでアクセスすると `complete(account.name)` が実行されることが確認できる。

```
$ curl -H "Authorization: Bearer 123456789" --dump-header - http://localhost:8080/
HTTP/1.1 200 OK
Server: akka-http/10.0.0
Date: Tue, 06 Dec 2016 02:28:29 GMT
Content-Type: text/plain; charset=UTF-8
Content-Length: 4

user
```

トークンが間違っていた場合

```
$ curl -H "Authorization: Bearer invalid" --dump-header - http://localhost:8080/
HTTP/1.1 401 Unauthorized
WWW-Authenticate: bearer,error=invalid_token
Server: akka-http/10.0.0
Date: Tue, 06 Dec 2016 02:31:10 GMT
Content-Type: text/plain; charset=UTF-8
Content-Length: 38

The supplied authentication is invalid
```

`Authorization`ヘッダーを付けなかった場合

```
$ curl --dump-header - http://localhost:8080/
HTTP/1.1 401 Unauthorized
WWW-Authenticate: bearer,error=invalid_token
Server: akka-http/10.0.0
Date: Tue, 06 Dec 2016 02:32:42 GMT
Content-Type: text/plain; charset=UTF-8
Content-Length: 77

The resource requires authentication, which was not supplied with the request
```

ちなみに `AuthenticationDirective[T]` のようなディレクティブは簡単に作ることができる。よく使うのは `Directive0` と `Directive1[T]` の2つで、AuthenticationDirectiveもDirective1[T]が元になっている。前者は値を返さないディレクティブで後者は次の処理に値を渡す。

Directive0は`pass`か`reject`でハンドリングする。Directive1は`provide`で返す値を包む。汎用的なディレクティブを作っておけば、RailsのActionControllerのfilterのように使うことが出来るので活用していきましょう。

```scala
def directive0(str: String): Directive0 =
  if (str == ????) pass
  else reject()

def directive1(str: String): Directive1[String] =
  if (str == ????) provide(str.toUpperCase)
  else reject()

val routes = path("users" / Segment) { str =>
  directive0(str) {
    directive1(str) { result =>
      complete(result)
    }
  }
}
```

