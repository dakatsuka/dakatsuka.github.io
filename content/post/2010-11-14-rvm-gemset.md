---
title: RVMのgemsetを使ってみる
slug: rvm-gemset
date: 2010-11-14
tags: [Ruby, Rails]
---

Rubyの開発環境にRVMを使っている場合は、bundle install –pathを使うよりもgemsetという機能を使ったほうがお手軽に管理出来るみたいです。

```sh
$ rvm gemset create hoge-project
$ rvm gemset use hoge-project
$ bundle install
```

どのgemsetを使用しているか確認

```sh
$ rvm gemset name
hoge-project
```

gemsetの一覧を表示

```sh
$ rvm gemset list
gemsets : for ruby-1.9.2-p0 (found in /home/user/.rvm/gems/)
global
hoge-project
```
