---
title: Rails v3.0.xからv3.1.0にアップグレードした時のメモ
date: 2011-09-01
tags: Ruby, Rails
---

Rails v3.1.0が出たのでv3.0.10で開発しているプロジェクトの対応を行いました。その時のメモを残しておきます。

といっても、このRailsプロジェクトはJSONを返すだけの単純なREST APIでしたので修正箇所は少なかったです。あまり参考にならないかもしれません。。。

Gemfileを開き、Rails, Rake, mysql2のバージョンを上げます。

```diff
-gem 'rails',                '3.0.10'
-gem 'rake',                 '0.8.7'
-gem 'mysql2',               '0.2.11'
+gem 'rails',                '3.1.0'
+gem 'rake',                 '0.9.2'
+gem 'mysql2',               '0.3.7'
```

おなじみBundlerでgemを更新します。

```
$ bundle update
```

問題なく動作するかテストを走らせてみます。

```
$ rake spec
rake aborted!
undefined method `debug_rjs=' for ActionView::Base:Class
 
Tasks: TOP => spec => db:test:prepare => db:abort_if_pending_migrations => environment
(See full trace by running task with --trace)
```

……どうやら[debug\_rjs というメソッドが無くなった](https://github.com/rails/rails/commit/d8f23ca627df85b33fe8db87db5483c10b62bfe6)ようです。config/environments/development.rbから該当の行を削除します。

```diff
-  config.action_view.debug_rjs = true
```

以上を修正するだけで対応することが出来ました。色々と書き直しが発生しなくて一安心です。
