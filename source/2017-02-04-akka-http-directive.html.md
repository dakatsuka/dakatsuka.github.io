---
title: Akka HTTPのDirective0の使い勝手が良くないのでどうにかする話
date: 2017-02-04
tags: Scala, Akka
---

まず`Directive0`と`Directive1`の型定義を見て欲しい。

```scala
type Directive0 = Directive[Unit]
type Directive1[T] = Directive[Tuple1[T]]
```

`Directive0`が`Directive1[Unit]`であればそこまで問題なかったのだが、このように型パラメータは`Unit`と`Tuple1[T]`となっている。なぜこのような定義になっているのかは正確には分からないけど、おそらくDSLとしての使い勝手を優先したのだと思う。`directive0 { _ => ... }` よりは `directive0 { }` と書けたほうが良い的な。

また`Directive1`にはimplicit conversionで`map`と`flatMap`が実装されているのでfor式で扱うことができるが、`Directive0`にはその2つのメソッドは存在しない（代わりに`tmap`と`tflatMap`はある）つまり両方を同時にfor式で処理することができないという問題が発生する。

次のようなコードは動かない。

```scala
for {
  value1 <- directive1A
  _      <- directive0A
  value2 <- directive1B
} yield (value1, value2)
```

`Directive0`はそんなに利用頻度は高くないのだけど、バリデーションや認可など値を返さずに処理を通すか通さないかだけを判断するところでは使うので、これではちょっと困る。Akka HTTP的にはfor式など使わずにひたすらネストさせていくのを推奨しているのかもしれないけど。。。でもfor式も使いたい！

というわけでimplicit conversionで`Directive0`に`map`と`flatMap`を生やす。ついでに`Directive1[Unit]`としても振る舞えるように型変換もしておく。

```scala
implicit class Directive0ForComprehensionSupport(directive0: Directive0) {
  def map[T](f: Unit => T): Directive1[T] = directive0.tmap(f)
  def flatMap[T](f: Unit => Directive1[T]): Directive1[T] = directive0.tflatMap(f)
}

implicit def directive0ToDirective1(directive0: Directive0): Directive1[Unit] =
  directive0.tflatMap(provide)
```

ちょっとワークアラウンドっぽいやり方だけどやりたい事は実現できる。ご利用は計画的に👻
