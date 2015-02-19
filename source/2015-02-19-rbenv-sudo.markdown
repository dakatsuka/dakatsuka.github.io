---
title: rbenv-sudoが便利
date: 2015-02-19
tags: Ruby
---

理想

```
$ sudo bundle exec rake
```

現実

```
$ sudo bundle exec rake
sudo: bundle: command not found
```

sudoで実行すると環境変数が初期化されているので当然の挙動ですが、システムワイドに入れていないrbenv環境下でもroot権限で実行したいことが稀にあります（docker-api使いたいとか

そういう時は[rbenv-sudo](https://github.com/dcarley/rbenv-sudo)を使うと解決します。自分でパスを弄ったりしなくても良いのでお手軽。rbenvのプラグインなので`~/.rbenv/plugins`にcloneするだけで使えます。

```
$ rbenv sudo bundle exec rake
```
