---
title: Play framework を CircleCI でテストする
date: 2014-08-24
tags: Scala,Play,CI
---

Play framework 2.3 (Scala版）で開発しているアプリをTravis ProでCIしていたのだけど、ビルド時間がネックになってきたのでインスタンス性能が高いと噂のCircleCIに移行することにした。

[CircleCIの対応言語](https://circleci.com/docs/languages)の中にScalaは入っていないが、Javaが使えるので特に問題はない（何故かちょっと古いsbtが入っていたのでexperimental扱いなのかな？）

circle.ymlは下記のようにしてる。

```yaml
dependencies:
  cache_directories:
    - ~/.m2
    - ~/.ivy2
    - ~/.sbt

  override:
    - "./activator update"

database:
  override:
    - cp ./conf/test.conf.circleci ./conf/test.conf

test:
  override:
    - "./activator clean test"

deployment:
  development:
    branch: master
    commands:
      - pip install -r requirements.txt
      - fab dev deploy
```

Travis ProからCircleCIに移行して、CIにかかる時間が4分の1に短縮されて満足度高い。
