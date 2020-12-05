---
title: Play Framework 2.x でマルチプロジェクト構成にするには
slug: play-multiple-project
date: 2015-06-11
tags: [Scala, sbt, Play]
categories: ["Programming"]
---

ドメイン層（普通のScalaプロジェクト）とアプリケーション層（Play）でsbtプロジェクトを分けたい場合は、sbtのマルチプロジェクトを使うと良い。

完全にリポジトリごとに分けても良いのだけど、IDEのリファクタリング機能などの便利機能の恩恵を受けたいとか、開発初期でドメインの更新が頻繁にあるなら、同一リポジトリでマルチプロジェクト構成のほうがおすすめ。

ディレクトリ構成は下記のようにする。

<pre><code>.
├─ project/
|   └─ plugin.sbt
├─ domain/
|   ├─ src/
|   └─ build.sbt
├─ api/
|   ├─ app/
|   ├─ conf/
|   ├─ logs/
|   ├─ public/
|   ├─ test/
|   └─ build.sbt
└─ build.sbt
</code></pre>

sbtはサブプロジェクト内のprojectディレクトリを無視するので、Playのsbt-pluginなどはメインプロジェクトで読み込む。

project/pugin.sbt

```scala
resolvers += "Typesafe repository" at "http://repo.typesafe.com/typesafe/releases/"

addSbtPlugin("com.typesafe.play" % "sbt-plugin" % "2.4.0")
```

またライブラリの依存関係はサブプロジェクトのbuild.sbtでは行わず、全てメインプロジェクトのbuild.sbtに記述していく。`commonSettings`で共通の設定や依存ライブラリを定義しておくと便利。

build.sbt

```scala
name := "myapplication"

lazy val commonSettings = scalariformSettings ++ Seq(
  organization := "org.example",
  scalaVersion := "2.11.6",
  resolvers += "scalaz-bintray" at "https://dl.bintray.com/scalaz/releases",
  libraryDependencies ++= Seq(
    "org.specs2"      %% "specs2-core"            % "3.6.1"  % "test",
    "org.specs2"      %% "specs2-mock"            % "3.6.1"  % "test",
    "org.specs2"      %% "specs2-junit"           % "3.6.1"  % "test",
    "ch.qos.logback"  %  "logback-classic"        % "1.1.+"
  )
)

lazy val domain = project.in(file("domain"))
  .settings(commonSettings: _*)
  .settings(
    libraryDependencies ++= Seq(
      "mysql"           %  "mysql-connector-java"   % "5.1.31",
      "org.scalikejdbc" %% "scalikejdbc"            % "2.2.+",
      "org.scalikejdbc" %% "scalikejdbc-config"     % "2.2.+",
      "org.scalikejdbc" %% "scalikejdbc-test"       % "2.2.+"  % "test"
    )
  )

lazy val api = (project.in(file("api")))
  .enablePlugins(PlayScala)
  .settings(commonSettings: _*)
  .settings(
    libraryDependencies ++= Seq(
      jdbc,
      cache,
      ws,
      "com.typesafe.play" %% "play-specs2"                  % "2.4.0"       % "test",
      "org.scalikejdbc"   %% "scalikejdbc-play-initializer" % "2.4.0.RC1",
      "org.scalikejdbc"   %% "scalikejdbc-play-fixture"     % "2.4.0.RC1",
    )
  )
  .dependsOn(domain)
```

サブプロジェクトのbuild.sbtには`name` `version` `javaOptions`などを個別に定義していく。

Playでサーバを起動する場合は下記コマンドを使う。テストをサブプロジェクト単位で実行する場合も同様。

```
$ sbt "project api" run
$ sbt "project api" test
$ sbt "project domain" test
$ sbt test // all test
```
