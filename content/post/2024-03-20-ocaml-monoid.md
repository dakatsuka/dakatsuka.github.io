---
title: OCamlでモノイド
slug: ocaml-monoid
date: 2024-03-20T22:00:00+09:00
tags: [OCaml]
---

OCamlには型クラスはないが、ファンクターでそれっぽい雰囲気のものは作れそうだなと思ったので試してみた。

まずはモノイドを表すモジュール型を定義。シグネチャの関数名は `zero` や `combine` でも好きな名前で良いと思います。

```ocaml
module type Monoid = sig
  type t

  (* 単位元 *)
  val empty : t

  (* 二項演算。実装では結合法則を守る必要がある *)
  val append : t -> t -> t
end
```

ファンクターは以下のように `MakeMonoid` とした。
```ocaml
(* ファンクター *)
module MakeMonoid (M : Monoid) = struct
  type t = M.t

  let empty = M.empty
  let append = M.append
end

(* Monoidのシグネチャを満たしたモジュールを定義 *)
module MyInt = struct
  type t = int
  let empty = 0
  let append = ( + )
end

(* int専用のMonoidモジュールを作成 *)
module IntMonoid = MakeMonoid (MyInt)
```

IntMonoid を使ってみる。当然のようにint型の二項演算ができる。
```ocaml
IntMonoid.empty
(* - : int = 0 *)

IntMonoid.append 10 10
(* - : int = 20 *)

IntMonoid.append 10 (IntMonoid.append 10 IntMonoid.empty)
(* - : int = 20 *)

IntMonoid.append (IntMonoid.append 10 IntMonoid.empty) 10
(* - : int = 20 *)
```

これだけだと味気ないので畳み込みを実装してみた。

```ocaml
(* Foldableなモジュールを作成するファンクター *)
module MakeFoldable (M : Monoid) = struct
  include MakeMonoid (M)

  let fold = List.fold_left append empty
end

(* int専用のFoldableモジュールを作成 *)
module IntFoldable = MakeFoldable (MyInt)

IntFoldable.fold [1; 2; 3; 4; 5]
(* - : int = 15 *)
```

まぁ int 単体だと旨味が少ないかもしれないけど、自作した型を畳み込みしたい！とか、既存の型が実はモノイドの要件を満たしていたので畳み込みしたいなというケースで使えそう。

```ocaml
type row = {
  a : int;
  b : int;
  c : int;
}

module RowFoldable = MakeFoldable (struct
  type t = row
  let empty = { a = 0; b = 0; c = 0 }
  let append x y = { a = x.a + y.a; b = x.b + y.b; c = x.c + y.c }
end)

let row1 = { a = 100; b = 100; c = 100; }
let row2 = { a = 100; b = 200; c = 100; }
let row3 = { a = 100; b = 300; c = 100; }
let rows = [row1; row2; row3;]

RowFoldable.fold rows
(* - : row = {a = 300; b = 600; c = 300} *)
```

## fold_map
fold_map を実装する場合は少し工夫がいる。fold_map に渡す関数の戻り値を畳み込む必要があるため、ファンクターの第二引数でも `Monoid` を渡してこちらで処理するように変える。

```ocaml
module MakeFoldable (M : Monoid) (O : Monoid) = struct
  include MakeMonoid (M)

  type out = O.t

  let fold = List.fold_left append empty
  let fold_map f = List.fold_left (fun x y -> O.append x (f y)) O.empty
end

module ListIntFoldable =
  MakeFoldable
    (struct
      type t = int list

      let empty = []
      let append = List.append
    end)
    (MyInt)

ListIntFoldable.fold [ [1;2]; [3;4;5]; [6] ]
(* - : int list = [1; 2; 3; 4; 5; 6] *)

ListIntFoldable.fold_map (fun xs -> List.length xs) [ [1;2]; [3;4;5]; [6] ]
(* - : int = 6 *)
```