---
title: The Magnet PatternでAkka HTTPのonSuccessで処理できる型を増やす
slug: akka-http-onsuccess-magnet
date: 2017-02-18
tags: ["Scala", "Akka"]
categories: ["Programming"]
---

Akka HTTPの onSuccess ディレクティブは [The Magnet Pattern](http://spray.io/blog/2012-12-13-the-magnet-pattern/) によって実装されているので`OnSuccessMagnet`型クラスのインスタンスさえ定義してしまえば割りと何でも受け取ることができる。型が`M[Future[A]]`になっているオブジェクトをそのまま`onSuccess`に渡したくなった時のために覚えておくと良いかもしれない。

例えば、次のコードで`Directive[Tuple1[Future[A]]]`に対応することが可能。

```scala
implicit def directiveIncludingFuture[T](futureDirective: Directive[Tuple1[Future[T]]])(implicit tupler: Tupler[T]): OnSuccessMagnet { type Out = tupler.Out } = {
  new OnSuccessMagnet {
    type Out = tupler.Out
    val directive: Directive[Out] = futureDirective.flatMap { future =>
      Directive[tupler.Out] { inner => ctx =>
        import ctx.executionContext
        future.fast.flatMap(t => inner(tupler(t))(ctx))
      }(tupler.OutIsTuple)
    }(tupler.OutIsTuple)
  }
}
```

`Directive[Tuple1[Future[A]]]`なんてそう滅多に出てこないでしょ…と思うかもしれないが、複数の Directive1 から取得した値を非同期で処理するというシチュエーションはそれなりにあるかもしれない。

こんな感じのやつ。

```scala
val result = for {
  value1 <- directive1
  value2 <- directive2
} yield hogeAsyncRepository.findBy(value1, value2) // resultの型は Directive[Tuple1[Future[Option[A]]]] になる

onSuccess(result) {
  case Some(_) => complete(OK)
  case None    => complete(NotFound)
}
```
