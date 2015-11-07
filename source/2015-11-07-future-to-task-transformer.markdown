---
title: scala.concurrent.Futureをscalaz.concurrent.Taskに変換する方法
date: 2015-11-07
tags: Scala
---

あまり良い方法では無さそうだけど他に思いつかなかった

```scala
import scala.concurrent.Future
import scala.concurrent.ExecutionContext.Implicits.global
import scala.util.{Success, Failure}
import scalaz.concurrent.Task
import scalaz.syntax.either._

implicit class FutureToTaskTransformer[+A](future: Future[A]) {
  def toTask: Task[A] = {
    Task.async { register =>
      future.onComplete {
        case Success(v) => register(v.right)
        case Failure(e) => register(e.left)
      }
    }
  }
}
```

Future型を返してくる何かをhttp4sで使いたいときに使えるかも？
