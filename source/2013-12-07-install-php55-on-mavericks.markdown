---
title: HomebrewでPHP5.5を入れようと思ったら手間取った話
date: 2013-12-07
tags: PHP
---

MavericksにHomebrewを使ってPHP 5.5をインストールしようと思ったら次のようなエラーが出てきた。

```
configure: error: freetype.h not found.
```

対処法はHomebrewを更新してfreetypeを消せば良いようだ。同じMavericksでもMBAのほうではエラーが出なかったので、多分バグが混じったバージョンを踏んでしまったんだと思う。

```
$ brew update
$ brew upgrade
$ brew unpin freetype && brew unlink freetype && brew rm freetype
$ brew install php55
```

参考

- [error freetype.h not found installing php53 · Issue #885 · josegonzalez/homebrew-php](https://github.com/josegonzalez/homebrew-php/issues/885)
