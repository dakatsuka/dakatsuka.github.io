---
title: ファーストクラスモジュール
slug: ocaml-first-class-module-memo
date: 2024-03-24T22:00:00+09:00
tags: [OCaml]
---

OCamlにはファーストクラスモジュール（第一級モジュール）という言語機能があり、関数の引数にモジュールを渡したりモジュールを戻り値にすることができる。

典型的な使い方は、関数の引数に要求するモジュール型を指定しておきそのシグネチャに合致したモジュールを渡せるようにして、関数内でモジュールの実装を呼び出す。Strategy PatternやDIとして使えるだろう。[公式マニュアル](https://v2.ocaml.org/manual/firstclassmodules.html)でも select at run-time among several implementations と言っているのでそういう使い方を想定しているはず。

```ocaml
(* インターフェースを定義 *)
module type DigestStrategy = sig
  val to_hex : string -> string
end

(* MD5のハッシュ値を返す *)
module DigestMD5 = struct
  let to_hex s = Digestif.MD5.to_hex (Digestif.MD5.digest_string s)
end

(* SHA1のハッシュ値を返す *)
module DigestSHA1 = struct
  let to_hex s = Digestif.SHA1.to_hex (Digestif.SHA1.digest_string s)
end

(* 第一引数でモジュールを受け取る関数 *)
let print_hex_digest (module S : DigestStrategy) s = S.to_hex s |> print_string

let () =
  print_hex_digest (module DigestMD5)  "test"; (* 098f6bcd4621d373cade4e832627b4f6 *)
  print_hex_digest (module DigestSHA1) "test"; (* a94a8fe5ccb19ba61c4c0873d391e987982fbbd3 *)
```

また、以下のように `t` 型を抽象化することで、引数や戻り値の型も変えることができる。これはScalaの[Dependent function types](https://docs.scala-lang.org/scala3/book/types-dependent-function.html)に近く、なかなかpowerfulだなぁと感じる。

```ocaml
module type Monoid = sig
  type t
  val empty : t
  val append : t -> t -> t
end

module IntMonoid = struct
  type t = int
  let empty = 0
  let append = ( + )
end

module StrMonoid = struct
  type t = string
  let empty = ""
  let append = ( ^ )
end

let add (type s) (module M : Monoid with type t = s) a b = M.append a b

add (module IntMonoid) 10 10
(* - : int = 20 *)

add (module StrMonoid) "foo" "bar"
(* - : string = "foobar" *)
```

再帰関数で使う場合、型注釈が必要になるらしい。正直、ここまでやるとシンタックス的に可読性にやや難があるような気もする（極めるとそうでもないのかもしれない）素直に別メソッドとして実装するかファンクターを作るくらいで良いんじゃないかなって思わなくもない。
```ocaml
let rec sum : type s. (module Monoid with type t = s) -> s list -> s =
 fun (module M : Monoid with type t = s) xs ->
  match xs with
  | [] -> M.empty
  | x :: rest -> M.append x (sum (module M) rest)

sum (module IntMonoid) [ 1; 2; 3; 4 ]
(* - : int = 10 *)

sum (module StrMonoid) [ "foo"; "bar" ]
(* - : string = "foobar" *)
```

## 参考文献
- https://v2.ocaml.org/manual/firstclassmodules.html
- [IQ1とOCamlとFirst-classモジュール - ちゃっくのメモ帳](https://chakku.hatenablog.com/entry/2019/12/01/000151)