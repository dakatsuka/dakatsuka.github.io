---
title: finagle-mysqlのClient (IO Context) をReaderTで受け取る
date: 2015-12-15
tags: Scala, Scalaz, Finch, Finagle
---

下準備としてパッケージオブジェクトあたりに以下のおまじないを書いておく[^1] この時点ですでに面倒だ！

```scala
import com.twitter.util.Future
import scalaz._
import Scalaz._

implicit def FutureFunctor: Functor[Future] = new Functor[Future] {
  def map[A, B](f: Future[A])(map: A => B): Future[B] = f.map(map(_))
}

implicit def FutureMonad: Monad[Future] = new Monad[Future] {
  def point[A](a: => A) = Future.value(a)
  def bind[A, B](f: Future[A])(fmap: A => Future[B]) = f.flatMap(fmap(_))
}

type ReaderTFuture[A, B] = ReaderT[Future, A, B]

object ReaderTFuture extends KleisliInstances with KleisliFunctions {
  def apply[A, B](f: A => Future[B]): ReaderTFuture[A, B] = kleisli(f)
}
```

[Finch + MySQLでREST APIサーバを構築する](/2015/12/07/finch.html)で書いたUserがimplicit parameterを使ってClientを受け取っているので、これをReaderTに置き換えてみた。

```scala
import com.twitter.finagle.exp.mysql._

case class User(id: Long, email: String, screen_name: String)

object User {
  def find(id: Long) = ReaderTFuture[Client, Option[User]] { client =>
    client.prepare("SELECT * FROM users WHERE id = ?")(id) map { result =>
      result.asInstanceOf[ResultSet].rows.map(convertToEntity).headOption
    }
  }

  def create(email: String, screen_name: String) = ReaderTFuture[Client, Long] { client =>
    client.prepare("INSERT INTO users (email, screen_name) VALUES(?, ?)")(email, screen_name) map { result =>
      result.asInstanceOf[OK].insertId
    }
  }

  def convertToEntity(row: Row): User = {
    val LongValue(id)            = row("id").get
    val StringValue(email)       = row("email").get
    val StringValue(screen_name) = row("screen_name").get

    User(id, email, screen_name)
  }
}
```

こんな感じで使うことができる。

```scala
val client = Mysql.client
  .withCredentials("user", "password")
  .withDatabase("database")
  .newRichClient("127.0.0.1:3306")

(for {
  id   <- User.create("user1@example.com", "user1")
  user <- User.find(id)
} yield user match {
  case Some(v) => Created(v)
  case _ => NotFound(new Exception("xxxxx"))
}).run(client)
```

上記のように`.run`でまとめて渡すことも出来るし`val user = User.find(id)(client)`と直接渡すことも出来るので、使いやすいほうを選べば良さそう。

### 参考文献

* [独習 Scalaz — モナド変換子](http://eed3si9n.com/learning-scalaz/ja/Monad-transformers.html)
* [Scala における Repository の実装パターンを考える -模索篇- - sandbox](http://tlync.hateblo.jp/entry/2013/12/12/023135)
* [Scala で IO コンテキストの共有を implicit 以外で解決する方法 (0) - sandbox](http://tlync.hateblo.jp/entry/2014/09/19/181608)
* [Scalaにおける最適なDependency Injectionの方法を考察する 〜なぜドワンゴアカウントシステムの生産性は高いのか〜 - Qiita](http://qiita.com/pab_tech/items/1c0bdbc8a61949891f1f)
* [【Scala Days 2014】The Reader Monad for Dependency Injection を解説してみた | Scala Tech Blog](http://adtech.cyberagent.io/scalablog/2015/01/16/readermonad4di/)

[^1]: FutureをFunctorとMonadの型クラスのインスタンスにしておく必要がある。ReaderTではなくReader使う場合は不要。
