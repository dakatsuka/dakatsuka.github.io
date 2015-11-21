---
title: Ubuntu Feistyのインストール
date: 2007-04-04
tags: Linux, Ubuntu
---

サブで使用しているノートPC（NEC LaVie G Type J）にUbuntu 7.04βを入れたのでそのメモ。

マシンスペックはこんな感じです。二世代ほど前のB5ノートです。

<table>
  <tr>
    <th>CPU</th>
    <td>Pentium-M 1.2GHz</td>
  </tr>
  <tr>
    <th>MEM</th>
    <td>1.25G</td>
  </tr>
  <tr>
    <th>HDD</th>
    <td>80GB</td>
  </tr>
  <tr>
    <th>GPU</th>
    <td>Intel 915GM</td>
  </tr>
</table>

## ではインストール

LiveCDをドライブに挿入してPCを起動させます。無事に起動したらまずGNOMEターミナルを開いて

```
sudo apt-get install gparted
```

とタイプしてGNOME Partition Editorをインストールします。NICが認識されていてDHCPな環境ならばサクっと入ります。というかEdgyにはデフォルトで入っていたのに何故外されたのでしょうか…不思議です。

私はgpartedを使って以下のようにパーティションを切りました。ReiserFSなのは私の好みです。普通はext3で問題ないと思います。

|Mount Point|Size|FS|
|-----------|----|---|
|/boot|100MB|ReiserFS|
|/|12GB|ReiserFS|
|/home|65GB|ReiserFS|
|swap|2GG|linux-swap|

後はデスクトップにあるInstallアイコンをダブルクリックして、ウィザードに従って進めていくだけでインストールが終わります。簡単すぎる…

インストール後の環境設定などはまた後日ということで。
