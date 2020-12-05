---
title: OCamlの開発環境を整えた
slug: setup-ocaml
date: 2016-01-31
tags: [OCaml]
categories: ["Programming"]
---

本当はローカルのMac OS X上に開発環境を構築したのだけど、メモを取り忘れていたので、改めてVagrantで起動したUbuntu 15.10上で開発環境を整えてみた。

まずシステムにOcamlとOPAMをインストールする。2016年1月時点ではOCaml 4.02.3が入った。

```
$ sudo add-apt-repository ppa:avsm/ppa
$ sudo apt-get update
$ sudo apt-get install ocaml ocaml-native-compilers camlp4-extra opam m4 git mercurial darcs
```

バージョンを確認。

```
$ ocaml -version
The OCaml toplevel, version 4.02.3

$ opam --version
1.2.2
```

OPAMを使うためには初期化が必要。このコマンドを実行すると `~/.opam` が作られる。

```
$ opam init
```

初期化が終わると下記メッセージが出てくるので指示に従う。

```
1. To configure OPAM in the current shell session, you need to run:

      eval `opam config env`

2. To correctly configure OPAM for subsequent use, add the following
   line to your profile file (for instance ~/.profile):

      . /home/vagrant/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true

3. To avoid issues related to non-system installations of `ocamlfind`
   add the following lines to ~/.ocamlinit (create it if necessary):

      let () =
        try Topdirs.dir_directory (Sys.getenv "OCAML_TOPLEVEL_PATH")
        with Not_found -> ()
      ;;
```

システムワイドにインストールされたOcaml環境はクリーンに保っておきたいので、開発用に新しい環境を用意しよう。`opam switch`コマンドで環境の作成や切り替えなどが行える。OPAMはパッケージ管理と環境管理がセットになったものと思っておけば良いだろう [^1]

```
$ opam switch install dev --alias-of 4.02.3
```

OCamlのソースコードをダウンロードしてきてコンパイルまでやってくれる。少し時間がかかるが、昨今のPCなら数分程度で終わるはず。

```
=-=- Installing compiler 4.02.3 -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
[default.comp] http://caml.inria.fr/pub/distrib/ocaml-4.02/ocaml-4.02.3.tar.gz downloaded
Now compiling OCaml. This may take a while, please bear with us...
Done.

=-=- Gathering sources =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

=-=- Processing actions -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
∗  installed base-bigarray.base
∗  installed base-ocamlbuild.base
∗  installed base-threads.base
∗  installed base-unix.base
Done.
# To setup the new switch in the current shell, you need to run:
eval `opam config env`
```

evalして環境を適用する。ocamlコマンドやopamコマンドのパスが変わっていることが確認できる。

```
$ eval `opam config env`
$ which ocaml
/home/vagrant/.opam/dev/bin/ocaml
```

VimやEmacsなどのエディタで補完を有効にするためにmerlinというライブラリを入れる。

```
$ opam install merlin
```

`.vimrc` に下記コードを追加すれば `.merlin` ファイルの存在するプロジェクトではオムニ補完が働くようになる。このファイルに依存するパッケージやモジュールを指定しないと駄目なのでちょっと面倒くさい。

```vim
syntax on
filetype plugin on

let g:opamshare = substitute(system('opam config var share'),'\n$','','''')
execute "set rtp+=" . g:opamshare . "/merlin/vim"
```

あとはutopやoasisなどをOPAMでインストールしておけば開発に取り掛かれると思う。なお、utopで日本語の扱いが残念なので`~/.ocamlinit`ファイルを作って下記コードを書いておくと良い。

```ocaml
let printer ppf = Format.fprintf ppf "\"%s\"";;
#install_printer printer
```

[^1]: RubyでいうところのGem + Bundler + rbenvがひとつのコマンドに集約された感じ
