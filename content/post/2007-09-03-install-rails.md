---
title: Ruby on Railsを導入する
slug: install-railsl
date: 2007-09-03
tags: [Ruby, Rails]
---

Railsで動くツールをいくつか試してみたくなったので、Ubuntuで環境を構築してみました。しょうもないですが手順をメモっておきます。

Rubyをapt-getでインストールします。libredcloth-rubyはredMineのWikiで使われるみたいです。

```sh
$ sudo apt-get install ruby rubygems libredcloth-ruby
```

gemでRailsをインストールします。

```sh
$ sudo gem install rails rake
```

/var/lib/gems/1.8/binにパスを通します。.bashrcをエディタで開いて

```sh
PATH="$PATH":/var/lib/gems/1.8/bin
```

上記を最下部に追加します。即反映させたい場合は

```sh
$ source ~/.bashrc
```

確認

```sh
$ which rails rake
/var/lib/gems/1.8/bin/rails
/var/lib/gems/1.8/bin/rake
```
