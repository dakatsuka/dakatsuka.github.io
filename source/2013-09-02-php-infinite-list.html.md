---
title: PHPで無限リストを作る
date: 2013-09-02
tags: PHP
---

PHPで range(0, 10000000); とかやるとメモリ不足で死んでしまうので、無限ループするイテレータを作ってみましょう。

```php
<?php
 
class Stream implements \Iterator
{
    private $position;
    private $offset;
    private $limit;
 
    public function __construct($offset, $limit = null)
    {
        $this->position = $offset;
        $this->offset   = $offset;
        $this->limit    = $limit;
    }
 
    public function current()
    {
        return $this->position;
    }
 
    public function next()
    {
        $this->position++;
    }
 
    public function valid()
    {
        if ($this->limit && $this->position > $this->limit) {
            return false;
        }
 
        return true;
    }
 
    public function key()
    {
        return $this->position;
    }
 
    public function rewind()
    {
        $this->position = $this->offset;
    }
 
    public function take($n)
    {
        return new \LimitIterator($this, 0, $n);
    }
}
```

無限ループさせる。

```php
<?php
$stream = new Stream(0);
 
foreach ($stream as $i) {
    echo $i . "\n";   
}

=>
// 0
// 1
// 2
// 3
// 4
// .
// .
```

範囲指定してみる。

```php
<?php
$stream = new Stream(50, 55);
 
foreach ($stream as $i) {
    echo $i . "\n";
}
 
=>
// 50
// 51
// 52
// 53
// 54
// 54
```

LimitIteratorを使えば無限リストから必要な数だけ取り出すことが出来ます。今回はtakeメソッドでラップしました。

```php
<?php
$stream = new Stream(0);
 
foreach ($stream->take(5) as $i) {
    echo $i . "\n";
}
 
=>
// 0
// 1
// 2
// 3
// 4
```

しかしこれだけだとあまり使い道がないので、せめてmap機能は欲しい気がしますね。イテレータオブジェクトにはarray\_系の関数が使えませんので、LazyMapIteratorを作ってみます。

```php
<?php
class LazyMapIterator implements \Iterator
{
    protected $iterator;
    protected $callback;
 
    public function __construct(\Iterator $iterator, callable $callback)
    {
        $this->iterator = $iterator;
        $this->callback = $callback;
    }
 
    public function getIterator()
    {
        return $this->iterator;
    }
 
    public function current(){
        $f = $this->callback;
        return $f($this->iterator->current());
    }
 
    public function next()
    {
        $this->iterator->next();
    }
 
    public function key()
    {
        return $this->iterator->key();
    }
 
    public function valid()
    {
        return $this->iterator->valid();
    }
 
    public function rewind()
    {
        $this->iterator->rewind();
    }
}
```

Streamクラスにmapメソッドを生やします。

```php
<?php
public function map(callable $f)
{
    return new LazyMapIterator($this, $f);
}
```

mapメソッドを使ってみます。


```php
<?php
$stream = new Stream(1, 5);
$result = $stream->map(function($i) {
    return $i * 10;
});
 
var_dump(iterator_to_array($result));
 
array(5) {
  [1] =>
  int(10)
  [2] =>
  int(20)
  [3] =>
  int(30)
  [4] =>
  int(40)
  [5] =>
  int(50)
}
```

ちなみにPHPはSPLで色々なイテレータが用意されていますので、PHPの残念な配列操作にイラついている方は是非覗いてみてください（CallbackFilterIteratorを使えばfilter機能もすぐ実装できます）
