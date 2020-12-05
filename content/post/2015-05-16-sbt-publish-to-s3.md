---
title: sbtでAmazon S3をMavenリポジトリとして扱う方法
slug: sbt-publish-to-s3
date: 2015-05-16
tags: [Scala, sbt, AWS]
categories: ["DevOps"]
---

[fm-sbt-s3-resolver](https://github.com/frugalmechanic/fm-sbt-s3-resolver)というプラグインを入れることでS3をMaven Repositoryとして扱えるようになります。社内のサーバにリポジトリを構築するよりお手軽です。

## Setup

project/plugin.sbt:

```scala
addSbtPlugin("com.frugalmechanic" % "fm-sbt-s3-resolver" % "0.5.0")
```

事前に`AWS_ACCESS_KEY_ID`と`AWS_SECRET_ACCESS_KEY`を環境変数で定義しておくこと。またはProperty Fileを`$HOME/.sbt`以下に作成しておく。

```sh
$ export AWS_ACCESS_KEY_ID=xxxxxx
$ export AWS_SECRET_ACCESS_KEY=xxxxx

or

$ cat ~/.sbt/.bucket-name_s3credentials
accessKey = xxxxxx
secretKey = xxxxxx
```

## Publish

build.sbtにPublish先を設定する。

```scala
publishTo := Some("Hoge Snapshots" at "s3://hoge-maven.s3-ap-northeast-1.amazonaws.com/hoge/snapshots")
```

これで`sbt publish`コマンドでS3にPublishできる。

## Usage
resolversにS3に置いたMavenリポジトリを追加する。

```scala
resolvers += "Hoge Snapshots" at "s3://hoge-maven.s3-ap-northeast-1.amazonaws.com/hoge/snapshots"
```

あとはライブラリと同様にlibraryDependenciesに依存関係を書いていくだけ。

```scala
libraryDependencies ++= Seq(
  "foo.bar" %% "hoge-project" % "1.0-SNAPSHOT"
)
```
