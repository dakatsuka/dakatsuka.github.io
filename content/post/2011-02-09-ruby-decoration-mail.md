---
title: Rubyでデコメールをパースするライブラリを作ってみた
slug: ruby-decoration-mail
date: 2011-02-09
tags: [Ruby]
---

モバイルサイトを開発・運営していると割と早い段階で上がってくる要望があります。

それは「デコメールに対応したい」

悪名高い「かんたんログイン」の次くらいに多い印象です。今回はこのデコメールをパースするライブラリを作成してみました。今のところデコメールの作成までは想定していませんが、自分が必要になったら実装し出すかもしれません（笑）

## ライブラリの特徴

* Rails3から採用されたActionMailerのバックエンド、Mailライブラリを少し拡張して利用します。
* デコメールのHTMLをXHTMLとインラインCSSに変換します。
* デコメールのHTMLからHTMLタグ、HEADタグ、BODYタグが削除されて本文のみ取得出来ます。
* デコメール画像のURLをContent-IDから自動でファイル名に置き換えます（変更可能）。
* DoCoMo / au / SoftBankから送られてくるメールをパース出来ます。

## 動作環境

Ruby 1.9.2-136 で動作検証を行っています。まだ試してませんが1.8.7でも動作すると思われます。

## インストール

gemコマンドでインストールします

```sh
gem install decoration_mail
```

もしくはGithubのリポジトリからcloneしてきます。

```sh
git clone git://github.com/dakatsuka/decoration_mail.git
```

## 使用方法

Mail::Messageクラスにdecorationというメソッドを追加していて、それを呼び出す事によってデコメールをパースした結果を返します。使い方は下記コードの通りです。

```ruby
# coding: utf-8
require 'rubygems'
require 'mail'
require 'decoration_mail'
 
# 普通は標準入力から受け取ると思います。
# Rails3ならreceiveメソッド内で既にインスタンスとして存在してるはずです。
@mail = Mail.read("/path/to/sample.eml")
@deco = @mail.decoration
 
@html = @deco.save do |image|
  File.open("/path/to/#{image.filename}", "wb") {|f| f.write(image.body)}
end
 
puts @html # => '<div style="......' # デコメール本文（XHTML）
```

saveメソッドの中で使えるブロック変数はデコメール画像のインスタンスが格納されています。このブロック変数では下記メソッドが使用可能です。

```ruby
@html = @deco.save do |image|
  image.content_id # => Content-ID 例： cid:xxxxxx
  image.filename   # => 画像のファイル名
  image.body       # => 画像データ
end
```

またpathを指定することで画像のURLを任意に指定することが出来ます（指定しない場合は画像のファイル名になります）。

```ruby
@html = @deco.save do |image|
  image.path = "http://image.example.com/#{image.filename}"
end
 
puts @html # => <img>タグのsrcが変わる
```

さらにsaveメソッドにother_imagesというオプションを指定することで、デコメール内で使用されていない添付画像をデコメに貼り付けることが出来ます。

```ruby
# デコメールの上部に挿入
@html = @deco.save(:other_images => :top) do |image|
end
 
# デコメールの下部に挿入
@html = @deco.save(:other_images => :bottom) do |image|
end
 
puts @html # => 出力されるXHTMLに添付画像のIMGタグが追加されています。
```

デコメールで使用していない画像を無視したい場合は、image.content_idがnilかどうかで判定出来ます。

```ruby
if image.content_id
else
end
```

以上です！まだ作ったばかり＆手元の実機が数台しか無いためバグが出る可能性があります。。。。その時は是非Twitter、もしくはGithub経由で報告して頂けると幸いです。

Github: [https://github.com/dakatsuka/decoration_mail](https://github.com/dakatsuka/decoration_mail)
