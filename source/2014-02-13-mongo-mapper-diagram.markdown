---
title: MongoMapperでER図っぽいものを生成するgemを作った
date: 2014-02-13
tags: Ruby,Rails
---

モデルの数がそれなりにあるプロジェクトに途中から参加すると、モデル同士の関連を把握するのに結構苦労するので、ER図の存在が重要になってくる。ActiveRecordなら[Rails ERD](http://rails-erd.rubyforge.org/)というgemを使えばER図を生成してくれるのだが、MongoMapper用のツールは無さそうだったので作った。

こんな感じの画像を生成できる。

![ダイアグラム](/uploads/2014/02/13/diagram.png)

まだ One-To-Many だけで Many-To-Many や Embedded には対応していないのだけど、ひとまず全体を把握するのには役にたった。余裕があれば対応していきたい。Pull requestも待ってます！

- [dakatsuka/mongo\_mapper\_diagram - GitHub](https://github.com/dakatsuka/mongo_mapper_diagram)

ちなみにグラフの生成には[@merborne](https://twitter.com/merborne)氏の[Gviz](https://github.com/melborne/Gviz)を使いました。Rubyから簡単にGraphvizが扱えて便利だった。

## 使い方

Gemfileに追加。

```ruby
group :development do
  gem "mongo_mapper_diagram"
end
```

Rakeタスクを実行するとRails.rootにdiagram.pngとdiagram.dotが生成される。

```
$ rake mongo_mapper:diagram
```
