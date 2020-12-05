---
title: PHPのmcrypt関数が遅すぎて辛い
slug: php-mcrypt-is-too-slow
date: 2013-08-12
tags: [PHP]
---

DES-ECBの暗号・復号を10万回繰り返すベンチマークを取ってみたらmcrypt関数が遅すぎて涙が出てきました。PHPのことなのでもっと速くなる書き方があると淡い期待をしているのですが、何か良い方法無いですかね(´・ω・`)

```php
<?php
 
$message = 'abcdefgh';
$key = 'abcdefgh';
 
for ($i = 0; $i < 100000; $i++) {
    $encryptedMessage = mcrypt_encrypt(MCRYPT_DES, $key, $message, MCRYPT_MODE_ECB);
    $decryptedMessage = mcrypt_decrypt(MCRYPT_DES, $key, $encryptedMessage, MCRYPT_MODE_ECB);
}
```

実行してみる。

```
$ php -v
PHP 5.4.13 (cli) (built: Apr 17 2013 12:40:07)
Copyright (c) 1997-2013 The PHP Group
Zend Engine v2.4.0, Copyright (c) 1998-2013 Zend Technologies
    with Xdebug v2.2.1, Copyright (c) 2002-2012, by Derick Rethans
 
$ time php ./bench.php
php ./bench.php  24.26s user 0.73s system 99% cpu 25.000 total
```

24秒…

同じ処理をPythonで書いてみました。

```python
import Crypto.Cipher.DES
 
message = "abcdefgh"
key = "abcdefgh"
 
for i in range(100000):
  cipher = Crypto.Cipher.DES.new(key, Crypto.Cipher.DES.MODE_ECB)
  encrypted_message = cipher.encrypt(message)
  decrypted_message = cipher.decrypt(encrypted_message)
```

実行してみると

```
$ python --version
Python 2.7.2
 
$ time python ./bench.py
python ./bench.py  0.92s user 0.01s system 99% cpu 0.930 total
```

1秒かかってませんね。。。RubyでOpenSSL::Cipherを使った場合もPythonとほぼ同速だったのでmcryptが異様に遅いのでしょうか？

## 追記
<ins>mcrypt関数ではなくOpenSSL関数 openssl_encrypt openssl_decrypt を使えば爆速になることがわかりました。PHP 5.3.0から使えるようなので特に理由がなければOpenSSLを使ったほうが良さそうです。</ins>
