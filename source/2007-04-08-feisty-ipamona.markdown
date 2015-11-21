---
title: FeistyでIPAモナーフォントを使う
date: 2007-04-08
tags: Linux, Ubuntu
---

日本語ローカライズ版が出るまでの繋ぎとして。

```
$ cd /tmp
$ wget http://www.geocities.jp/ipa_mona/opfc-ModuleHP-1.1.1_withIPAMonaFonts-1.0.5.tar.gz
$ tar zxvf opfc-ModuleHP-1.1.1_withIPAMonaFonts-1.0.5.tar.gz
$ cd opfc-*/fonts
$ sudo mkdir /usr/share/fonts/truetype/ttf-ipamona
$ sudo cp *.ttf /usr/share/fonts/truetype/ttf-ipamona
```

これで次回ログイン時からデフォルトのフォントがIPAモナーフォントになります。ならない場合は、

```
$ sudo gedit /etc/fonts/local.conf
```

で、geditを起動して

```xml
<fontconfig>
  <match target="pattern">
    <test qual="any" name="family">
      <string>sans-serif</string>
    </test>
    <edit name="family" mode="prepend" binding="strong">
      <string>IPAMonaPGothic</string>
    </edit>
  </match> 
  <match target="pattern">
    <test qual="any" name="family">
      <string>serif</string>
    </test>
    <edit name="family" mode="prepend" binding="strong">
      <string>IPAMonaPMincho</string>
    </edit>
  </match> 
  <match target="pattern">
    <test qual="any" name="family">
      <string>monospace</string>
    </test>
    <edit name="family" mode="prepend" binding="strong">
      <string>IPAMonaGothic</string>
    </edit>
  </match> 
</fontconfig>
```

上記を貼りつけて保存すればフォントが置き換わるはずです。多分
