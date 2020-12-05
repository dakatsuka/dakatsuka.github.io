---
title: PHP 5.4のトレイトで読み取り専用配列を実装してみる
slug: php54-trait-readonly-array
date: 2013-03-10
tags: [PHP]
---

traitを使って何か作ってみようと思い立ち、読み取り専用の配列を実装してみました。配列として扱いたい（例えばforeachで回したいとか）けど外側からの変更は受け付けたくないというシチュエーションで使えます。

```php
<?php
trait ReadOnlyArray
{
    private $items = [];
 
    public function offsetGet($key)
    {
        if (!array_key_exists($key, $this->items)) {
            throw new OutOfRangeException();
        }
 
        return $this->items[$key];
    }
 
    public function offsetSet($key, $value)
    {
        throw new BadMethodCallException();
    }
 
    public function offsetExists($key)
    {
        return isset($this->items[$key]);
    }
 
    public function offsetUnset($key)
    {
        throw new BadMethodCallException();
    }
 
    public function getIterator()
    {
        return new ArrayIterator($this->items);
    }
 
    public function count()
    {
        return count($this->items);
    }
}
```

使い方は以下の通り。

```php
<?php
class ExampleArray implements ArrayAccess, IteratorAggregate, Countable
{
    use ReadOnlyArray;
 
    public function __construct()
    {
        $this->items["foo"] = "bar";
    }
}
 
$example = new ExampleArray();
$example["foo"];         // => "bar"
$example["foo"] = "buu"; // => BadMethodCallException
$example->count();       // => 1
```
