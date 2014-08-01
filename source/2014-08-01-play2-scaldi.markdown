---
title: Play framework 2.3.x と Scaldi で Dependency Injection
date: 2014-08-01
tags: Scala,Play,DI
---

Play2でDIをどうしようか悩んでいたところ[scaldi](http://scaldi.org/)というライブラリが目に止まった。Playに組み込むためのライブラリをあるし、公式サイトも作り込まれているし、これは試すしかない。

ただし日本語の情報は無いに等しい。Guiceほどメジャーでもないし人柱感覚で使う必要がありそうだ。

## インストール

build.sbtのlibraryDependenciesにscaldiを追加する。

```scala
libraryDependencies ++= Seq(
  "org.scaldi" %% "scaldi-play" % "0.4.1"
)
```

## インジェクションの種類

コンストラクタ・インジェクションとバインディング・インジェクションの2種類があるようだ。

### コンストラクタ・インジェクション

名前の通り、コンストラクタで依存を受け取るパターン。scaldiに全く依存しないので通常はこのパターンを使うのが良いと思う。

```scala
package services

import repositories.AccountRepository

class AccountManager(accountRepository: AccountRepository)
```

### バインディング・インジェクション

ScaldiのInjector（コンテナ）を暗黙の引数で渡すパターン。コントローラなどはこちらを使う。

```scala
package controllers

import scaldi.{Injectable, Injector}

class Application(implicit inj: Injector) extends Controller with Injectable {
  val accountManager = inject [AccountManager]
}
```

## モジュールの作成

Injector（コンテナ）にサービスを登録するには Module を作成する必要がある。置く場所はどこでも良いのだがPlayならapp/modulesあたりに入れておくのが分かりやすいと思う。Moduleは複数定義して結合することが出来るので、うまく分割しておけばテストの時だけ別のModuleに差し替えるといったことが可能になる。

```scala
package modules

import scaldi.Module
import repositories._
import services._

class ServiceModule extends Module {
  bind [AccountRepository] to new AccountRepository
  bind [AccountManager]    to new AccountManager(inject[AccountRepository])
}

class ControllerInjector extends Module {
  binding to new Application
  binding to new FooController
  binding to new BarController
}
```

bindで型を指定してto以降に同一型のオブジェクトを作っていく感じ。inject[型]でbindで登録したものが取り出せるので各サービスのコンストラクタに渡すことが出来る。

Injectorを暗黙の引数で受け取るクラスはbinding toで指定していく。

また下記のようにbindで登録する時にシンボルで名前を付けることが出来る。Configurationのパラメータを登録しておく時に便利だろう。

```scala
bind [String] identifiedBy 'secret to Configuration(ConfigFactory.load()).getString("secret").getOrElse("hoge")
```

名前をつけたサービスを取り出す時は下記のようにする。

```scala
val secret = inject[String]('secret)
```

## モジュールをPlayに登録

scaldi-playは下記のようにGlobalに書いておくことで、リクエストが来た際に依存関係を自動で解決してくれるようになる。

app/Global.scal

```scala
import modules._
import play.api.GlobalSetting
import scaldi.play.ScaldiSupport

object Global extends GlobalSettings with ScaldiSupport {
  def applicationModule = new ControllerInjector :: new ServiceModule
}
```

## まとめ

Scaldi悪くないと思う。まだ使い出して日が浅いので罠が待ってるかもしれないけど、今のところ問題なく使えてる。DIの選択肢のひとつとしてどうですか。
