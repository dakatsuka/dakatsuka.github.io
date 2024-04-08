---
title: Extensible variant types
slug: ocaml-extensible-variant-types
date: 2024-04-08T19:00:00+09:00
tags: [OCaml]
---

Extensible variant types とは OCaml の言語拡張のひとつで、後からコンストラクタを拡張できる性質を持ったバリアント型を定義できる。

型を宣言するときは `..` を使う

```ocaml
 type color = ..
```

バリアントに新しいコンストラクタを追加するときは `+=` を使う

```ocaml
type color += Red
type color +=
  | Blue
  | Green
  | Rgb of { r: int; g: int; b: int }
```

後から型を拡張できる特性から、パターンマッチングでは網羅することができないため、未知のコンストラクタを処理するためのデフォルトケースが必要になっている。Scalaで例えるとsealed無しのMarker Traitみたいな感じか

```ocaml
let string_of_color = function
  | Red -> "red"
  | Blue -> "blue"
  | Green -> "green"
  | Rgb {r; g; b} -> "RGB(" ^ (string_of_int r) ^ ", " ^ (string_of_int g) ^ ", " ^ (string_of_int b) ^ ")"
  | _ -> "unknown"
```

実は OCaml の例外は Extensible variant types が使われている。utopで確かめてみる

```ocaml
# exception Foo_exception of int;;
# Foo_exception 10;;
- : exn = Foo_exception 10
```

exn型の定義を見てみるとたしかに `..` となっているのが確認できる

```ocaml
# #show exn;;
type exn = ..
```

## 参考文献
- [Extensible variant types](https://v2.ocaml.org/manual/extensiblevariants.html)