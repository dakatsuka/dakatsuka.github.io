---
title: OCaml 4.08.0から使えるBinding operatorsが便利だった
slug: ocaml-binding-operators
date: 2021-01-11T19:20:00+09:00
tags: [OCaml]
categories: [Programming]
---

OCaml 4.08.0 で Binding operators [^1] という機能が導入されていました。これでOCamlでもHaskellのdo記法やScalaのfor式に近いかたちでモナディックな計算が可能になります。

4.08.0は結構前に出ているので今更感はありますが... 普段触っていないのがバレてしまう！

オプションモナドは以下のように書くことができます。

```ocaml
(* int -> int -> int option *)
let div x y = try Some (x / y) with Division_by_zero -> None

(* binding operators を定義 *)
let ( let* ) x f = Option.bind x f

let result =
  let* r1 = div 100 2 in
  let* r2 = div r1 10 in
  let* r3 = div r2 0 in (* None *)
  Some (r3 + 10)
in
match result with
| Some _ -> ""
| None   -> "上のコードだとr3の計算結果はNoneになるのでr3 + 10は実行されない"
```

モナドごとにモジュールを作ってローカルオープンするのが可読性も高くなり良さそうです。

```ocaml
module Option_ops = struct
  let ( let* ) x f = Option.bind x f
  let return = Option.some
end

let result =
  let open Option_ops in
  let* r1 = div 100 2 in
  let* r2 = div r1 10 in
  let* r3 = div r2 0 in
  return (r3 + 10)
```

ちなみに `let*` 以外にも `let+` や `and+` なども定義出来ます。使用できる記号はドキュメント[^2] を参照してください。

## 応用編

Binding operators は自分で定義しなければいけないという若干の面倒臭さがある反面、異なるモナドがネストしているような値に対しても柔軟に対応することができます。

例えば下記のように任意の型を内包できる `Io` 型があり、その中に `Result` 型が入っているケースです。IOは非同期処理の成功・失敗を表現し、Resultはビジネスロジックの成功・失敗を表現するような使い方ですね。

```ocaml
(* オレオレIO型 *)
module Io : sig
  type ('a, 'e) t = Success of 'a | Failure of 'e
  val bind : ('a, 'b) t -> ('a -> ('c, 'b) t) -> ('c, 'b) t
end = struct
  type ('a, 'e) t = Success of 'a | Failure of 'e
  let bind io f = match io with Success v -> f v | Failure _ as e -> e
end
```

次のように実装すると `Io.Success` 且つ `Result.Ok` のときだけ値を取り出して後続に処理を渡していくことができます。

```ocaml
module Io_result_ops = struct
  let ( let* ) x f =
    match x with
    | Io.Success (Ok v) -> f v
    | Io.Success (Error _ as e) -> Io.Success e
    | _ as e -> e
  let return x = Io.Success (Ok x)
end

let result =
  let open Io_result_ops in
  let* io1 = Io.Success (Ok 10) in
  let* io2 = Io.Success (Ok (io1 * 10)) in
  let* io3 = Io.Success (Ok (io2 * 10)) in
  let* io4 = Io.Success (Ok (io3 * 10)) in
  return io4;;
(* val result : ((int, 'a) result, 'b) Io.t = Io.Success (Ok 10000) *)

let result =
  let open Io_result_ops in
  let* io1 = Io.Success (Ok 10) in
  let* io2 = Io.Failure ("Internal Server Error") in
  let* io3 = Io.Success (Ok (io2 * 10)) in
  let* io4 = Io.Success (Ok (io3 * 10)) in
  return io4;;
(* val result : ((int, 'a) result, string) Io.t = Io.Failure "Internal Server Error" *)

let result =
  let open Io_result_ops in
  let* io1 = Io.Success (Ok 10) in
  let* io2 = Io.Success (Error(-1)) in
  let* io3 = Io.Success (Ok (io2 * 10)) in
  let* io4 = Io.Success (Ok (io3 * 10)) in
  return io4;;

(* val result : ((int, int) result, 'a) Io.t = Io.Success (Error (-1)) *)
```

こういうとき、ScalaやHaskellなどはモナドトランスフォーマーを使いますがOcamlのBinding operatorsでも似たようなことは出来ますよというお話でした。

[^1]: [8.23 Binding operators](https://caml.inria.fr/pub/docs/manual-ocaml/bindingops.html)
[^2]: [core-operator-char](https://ocaml.org/releases/4.11/htmlman/lex.html#core-operator-char)
