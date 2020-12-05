---
title: 今年に入って生み出した糞コード
slug: horrible-code
date: 2015-06-10
tags: [Python]
---

PackerのログからAMI IDを取得するコードがInvokeのタスクに書かれていた。全然書いた記憶がないのだけど（すごい忙しかったという記憶だけはある）blameしてみると自分なのできっと妖精さんが書いたのだろう。。。

```python
ami_id = commands.getoutput("ruby -e 'puts `tail -n1 /tmp/packer.log`.split(\": \").last'")
```

書きなおすとしたらこうかな。Pythonはたまにしか書かないのでもっと良い書き方がある気がする。

```python
with open("/tmp/packer.log", "r") as file:
  xs = file.read().split("\n")
  ami_id = [x for x in xs if x][-1].split(": ")[-1]
```

別にtailコマンド使うのは良い気がしてきた。

```python
ami_id = commands.getoutput("tail -n1 /tmp/packer.log").split(": ")[-1]
```

追記：これだ

```python
ami_id = commands.getoutput("tail -n1 /tmp/packer.log | sed -e 's/^ami: //'")
```
