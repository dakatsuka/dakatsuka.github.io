---
title: bundle installするときはpathを指定しよう
slug: bundle-install
date: 2010-11-09
tags: [Ruby, Rails]
---

Rails3からBundlerが導入されgemの管理がしやすくなりましたが、色々なRailsアプリでほいほいbundle installを実行するとシステムにインストールされるgemが結構カオスになってきます。また、Rails2とRails3が同居する開発環境だとかなり面倒くさくなります。精神衛生上あまり宜しくありません。

そこでbundlerにオプションを渡してgemを任意のディレクトリにインストールし、gemをRailsプロジェクト毎に管理することをオススメします。

Rails3の場合、使い方はこんな感じになります。

まず、プロジェクト用のディレクトリを作成し、Gemfileを記述します。

```sh
mkdir newapp
cd ./newapp
vim Gemfile
```

Gemfileにはrailsだけ指定します。

```ruby
source "http://rubygems.org"
gem "rails", "3.0.1"
```

Gemfileを書き終わったらbundleコマンドを使いRailsをインストールします。ここではvendor/bundlerというディレクトリにgemをインストールします。

```sh
bundle install --path vendor/bundler
```

インストールが終わったらRailsプロジェクトを作成します。RailsがGemfileを上書きしていいか質問してくるのでyesと答えて上書きしてしまいましょう。なお、インストールするディレクトリを変えた場合、そのディレクトリにはパスが通っていないのでbundle execを通してRailsを実行する必要があります。

```sh
bundle exec rails new .
```

あとは上書きされたGemfileを開いて、RSpecなりhamlなり導入したいgemを書いてbundle installしましょう。

毎回bundle execなんて打つの面倒過ぎるって人は、.bashrcや.zshrcにエイリアス設定しちゃいましょう。私は下記のようにしています。

```sh
alias be="bundle exec"
```

こうすることで、

```sh
be rake db:migrate
be rails s
```

みたいな感じで使っていくことが出来ます。
