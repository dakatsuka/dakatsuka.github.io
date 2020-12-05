---
title: ついカッとなってPHPでMaybeモナドを実装した
slug: php-maybe-monad
date: 2013-09-03
tags: [PHP]
---
PHPを仕事で使っているとis\_nullとかissetとかemptyとか===とかの存在にイライラしてくる訳ですよ。そこでなんちゃってMaybeモナドの登場です。

なんちゃってモナドなので実用性は怪しいですが、以下のように使えます（注意：ネタ記事なので真に受けないように）

```php
<?php

public function testLookupFunction()
{
    $lookup = function($key) {
        return function(array $d) use($key) {
            return isset($d[$key]) ? Maybe::ret($d[$key]) : Maybe::ret();
        };
    };
 
    $dictionary = ['a' => ['b' => ['c' => 10]]];
 
    $result1 = Maybe::ret($dictionary) [$lookup('a')] [$lookup('b')] [$lookup('c')];
    $result2 = Maybe::ret($dictionary) [$lookup('a')] [$lookup('Z')] [$lookup('c')];
 
    $this->assertInstanceOf('Just', $result1);
    $this->assertInstanceOf('Nothing', $result2);
    $this->assertEquals(10, $result1->get());
    $this->assertEquals(10, $result1->getOrElse(30));
    $this->assertNull($result2->get());
    $this->assertEquals(30, $result2->getOrElse(30));
}
```

モナド則（ちょっと自信無いかも）コードからPHPっぽさが消えた気が…

```php
<?php

/**
 * return a >>= f ≡ f a
 */
public function testMonadLaw1()
{
    $f = function($a) { return Maybe::ret($a * 3); };
    $l = Maybe::ret(5) [$f];
    $r = $f(5);
 
    $this->assertEquals($l, $r);
}
 
/**
 * m >>= return ≡ m
 */
public function testMonadLaw2()
{
    $m = Maybe::ret(5);
    $l = $m [function($x) { return Maybe::ret($x); }];
 
    $this->assertEquals($l, $m);
}
 
/**
 * (m >>= f) >>= g ≡ m >>= (\x -> f x >>= g)
 */
public function testMonadLaw3()
{
    $f = function($a) { return Maybe::ret($a * 3); };
    $g = function($a) { return Maybe::ret($a * 5); };
    $m = Maybe::ret(7);
    $l = $m [$f] [$g];
    $r = $m [function($x) use($f, $g) { return $f($x) [$g]; }];
 
    $this->assertEquals($l, $r);
}
```

## 実装

まずはMonadクラスを定義します。PHPは演算子のオーバーロードや新たな演算子を定義出来ないので、\>\>=はoffsetGetメソッドを書き換えて配列のブラケットで代用することにします。ブラケットの中にfunction {}って書けるので超キモイですね。

```php
<?php

abstract class Monad implements \ArrayAccess
{
    abstract public function bind(callable $f);
 
    public function offsetExists($offset)
    {
        throw new \BadMethodCallException();
    }
 
    public function offsetGet($offset)
    {
        return $this->bind($offset);
    }
 
    public function offsetSet($offset, $value)
    {
        throw new \BadMethodCallException();
    }
 
    public function offsetUnset($offset)
    {
        throw new \BadMethodCallException();
    }
}
```

次はMaybe、Just、Nothingクラスを定義します。NothingはNothingしか存在しないのでシングルトンにしてみました。また、ScalaのOption型で便利だったいくつかのメソッドを実装しています。

```php
<?php

abstract class Maybe extends Monad
{
    protected $value;
 
    public static function ret($value = null)
    {
        if (is_null($value)) {
            return Nothing::ret();
        } else {
            return Just::ret($value);
        }
    }
 
    public function __construct($value)
    {
        $this->value = $value;
    }
 
    public function bind(callable $f)
    {
        if ($this instanceof Just && is_callable($f)) {
            return $f($this->value);
        } else {
            return $this;
        }
    }
 
    abstract public function get();
    abstract public function getOrElse($default);
    abstract public function getOrCall(callable $fn);
    abstract public function getOrThrow(\Exception $ex);
    abstract public function isEmpty();
    abstract public function isDefined();
}
 
final class Just extends Maybe
{
    public static function ret($value = null)
    {
        return new Just($value);
    }
 
    public function get()
    {
        return $this->value;
    }
 
    public function getOrElse($default)
    {
        return $this->get();
    }
 
    public function getOrCall(callable $fn)
    {
        return $this->get();
    }
 
    public function getOrThrow(\Exception $ex)
    {
        return $this->get();
    }
 
    public function isEmpty()
    {
        return false;
    }
 
    public function isDefined()
    {
        return true;
    }
}
 
final class Nothing extends Maybe
{
    private static $instance;
 
    public function __construct($value = null)
    {
        if (static::$instance) {
            throw new \InvalidArgumentException();
        }
    }
 
    public static function ret($value = null)
    {
        if (is_null(static::$instance)) {
            return static::$instance = new static();
        } else {
            return static::$instance;
        }
    }
 
    public function get()
    {
        return null;
    }
 
    public function getOrElse($default)
    {
        return $default;
    }
 
    public function getOrCall(callable $fn)
    {
        return $fn();
    }
 
    public function getOrThrow(\Exception $ex)
    {
        throw $ex;
    }
 
    public function isEmpty()
    {
        return true;
    }
 
    public function isDefined()
    {
        return false;
    }
}
```

<del>Enjoy functional PHP!</del>
