---
title: Chefで始めるシステム構成管理入門 その1
slug: chef-introduction
date: 2011-12-05
tags: [Chef]
---

最近 Chef というシステムの構成を自動で管理するツールを使い始めました。同様のツールとして Puppet が有名ですが、レシピを内部DSLで記述出来るほうが自分には合っていると思ったので、今回は Chef を採用しました。折角覚えたので復習も兼ねてエントリを起こしてみます。このエントリがChefの導入を検討している方への手助けになれば幸いです。

## Chefの仕組み – 意外と依存関係が面倒なChef Server

{{<figure src="/media/2011-12-05-chef-introduction/chef.png">}}

Chefの基本的な仕組みは、サーバに設定を置き、クライアントがサーバに問い合わせるPull型のシステムです。クライアントはサーバからのレスポンスに従いパッケージのインストールなどを行います。しかし、Chef ServerはRuby(Merb), CouchDB, RabbitMQなど依存が多く、お世辞にもシンプルなシステムとは言えません。そのせいかネットで検索して出てくる情報もサーバを必要としない Chef-Solo を使ったものが多い印象です。

## 最低限覚えておきたい用語

Chefをインストールする前に覚えておきたい用語集です。たくさんありますがどれもChefを使いこなすためには必須の用語と言えるでしょう。ざっくりと概要を書いてみます。


### knife
Chef Server上で使用する管理コマンドです。後述のClinet, Node, Environmentなど全てこのコマンドで制御します。

### Client

Chef Serverに接続するもの全てを指します。Chef Serverからみた場合、Chefで管理するサーバ群は勿論のこと、knifeコマンドを使用する管理者もClinetになります。

### Node
Nodeは、Chef Serverに接続するClientのうち、Chefで管理するサーバ／マシンを指します。Clientとごっちゃになりやすいので注意。

{{<figure src="/media/2011-12-05-chef-introduction/chef-node-client.png">}}

ClientとNodeの関係を図で表すと上のようなイメージになります。

### Attributes
Attributesは、NodeのKernelのバージョンやディストリビューションの種類・バージョン、IPアドレスなどの様々な情報が記述されています。これらの情報はCookbookから参照することが可能で、Cookbook, Role, Environmentで値を追加・上書きすることも出来ます。

### Cookbook
Cookbookは、NodeにソフトウェアをインストールためのレシピでChefのメイン機能ですね。実際はインストールだけではなくてサーバの各種設定を変更したりユーザーやグループを作成したりと何でも出来ます。ERBで記述するTemplatesを使って動的に\*.confを生成する事も可能です。CookbookはNodeに直接割り当てるか、もしくはRole経由で使用します。

### Role
Roleは、Cookbookを複数束ねることができ、同じ構成のNodeをたくさん作るときに使用します。例えば昨今のWebサービスですと proxy, app, db という風に定義をするとイイ感じです。RoleはNodeに対して複数割り当てることが可能です。

### Environment
Environmentは、環境名を定義してNodeに割り当てる事ができます。RailsのEnvironmentと同じ概念ですね。環境毎にAttributesの値を変えたり、使用するCookbookのバージョンを指定・固定したり出来ます。本番環境とステージング環境ではデータベースのアドレスが違うだけなんて構成はよくあると思いますが、そういう時にこのEnvironmentが活躍します。

EnvironmentとRoleを制する者はChefを制す（大げさ）

---

と、長くなったのでその1はここで終了です。その2では実際にChef Serverをインストールして環境を整えるところまで書こうと思います。多分今週中には…
