---
title: ScalaでNumeric型クラスをつかう
slug: numeric-typeclass
date: 2015-12-27
tags: [Scala]
---

すごいHaskell本の序盤に次のような関数が出てくる。この関数はxが整数でも浮動小数点数でも動く。

```haskell
doubleMe x = x + x
```

ScalaでもNumeric型クラスをつかうことで同じように振る舞える。

```scala
def doubleMe[A](x: A)(implicit num: Numeric[A]): A = num.plus(x, x)
```

型クラスのインスタンスにしてしまえばどんな型にも対応できる。たとえば…

```scala
implicit val numericString = new Numeric[String] {
  def plus(x: String, y: String): String = x + y
  def minus(x: String, y: String): String = x - y
  def times(x: String, y: String): String = x * y
  def negate(x: String): String = s"-$x"
  def toInt(x: String): Int  = 0
  def toLong(x: String): Long = 0
  def toFloat(x: String): Float = 0
  def toDouble(x: String): Double = 0
  def fromInt(x: Int): String = x.toString
  def compare(x: String, y: String): Int = x compare y
}

doubleMe("a") // String = "aa"
```
