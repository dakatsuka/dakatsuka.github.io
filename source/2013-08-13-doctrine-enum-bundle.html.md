---
title: Symfony2(Doctrine2)でENUMを使うならDoctrineEnumBundleが便利
date: 2013-08-13
tags: PHP, Symfony2
---

[DoctrineEnumBundle](https://github.com/fre5h/DoctrineEnumBundle)というBundleを導入することによって、Doctrine2でMySQLのENUM型を扱うことができます。

## インストール

composer.jsonにfresh/doctrine-enum-bundleを追加します。

```json
{
    "require": {
        "php": ">=5.3.3",
        "symfony/symfony": "2.3.*",
        ........
        "fresh/doctrine-enum-bundle": "dev-master"
    }
}
```

composer.phar installを実行します。

```
$ php composer.phar install
```

app/AppKernel.phpにDoctrineEnumBundleを追加します。

```php
<?php
public function registerBundles()
{
    $bundles = [
        new Fresh\Bundle\DoctrineEnumBundle\FreshDoctrineEnumBundle()
    ];
}
```

## 使い方

まずEnumTypeクラスを作成します。

```php
<?php
 
namespace Acme\DemoBundle\EnumType;
 
use Fresh\Bundle\DoctrineEnumBundle\DBAL\Types\AbstractEnumType;
 
class GenderType extends AbstractEnumType
{
    const MALE   = 'male';
    const FEMALE = 'female';
 
    protected $name = 'GenderType';
 
    protected static $choices = [
        self::MALE   => '男性',
        self::FEMALE => '女性'
    ];
}
```

app/config/config.yml で上で作ったEnumTypeをDBALに登録します。


```yaml
doctrine:
    dbal:
        mapping_types:
            enum: string
        types:
            GenderType: Acme\DemoBundle\EnumType\GenderType
```

あとはENUM型にしたいメンバ変数に対してアノテーションでマッピングし、app/console doctrine:schema:updateを実行すればENUM型のカラムが作られます。

```php
<?php
 
namespace Acme\DemoBundle\Entity;
 
use Doctrine\ORM\Mapping as ORM;
 
/**
 * @ORM\Table
 * @ORM\Entity
 */
class User
{
    /**
     * @ORM\Column(name="gender", type="GenderType")
     */
    private $gender;
}
```
