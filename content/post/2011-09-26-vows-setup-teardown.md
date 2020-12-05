---
title: Vowsで前処理・後処理を行うには
slug: vows-setup-teardown
date: 2011-09-26
tags: [Node.js, TDD, BDD]
---

Vowsの場合、前処理はtopic内で行い、後処理はteardownを使用します。RSpecの after(:all) の動作に近い感じです。

```coffee
vows
  .describe("Hoge")
  .addBatch
    'a instance':
      # 前処理
      topic: ->
 
      'should hogehoge': (topic) ->
        assert.ok topic.hogehoge
 
      # 後処理
      teardown: (topic) ->
```

また、別のアプローチでaddBatchを利用する事も出来そうです。addBatchは順に実行されるので、前処理・後処理というよりは、一番最初・最後に実施したいテストなどがある場合に有効かもしれません。

```coffee
suite = vows.describe("Hoge")
suite.addBatch
  'first test':
    topic: ->
 
suite.addBatch
  'second test':
    topic: ->
 
suite.addBatch
  'last test':
    topic: ->
 
suite.export module
```

~~※ addBatch は、バッチごとにグローバルスコープが独立していますので、グローバルスコープに影響が出る処理（console.log をモック化する時など）に最適かも。~~

どうもそうでは無いようです…
