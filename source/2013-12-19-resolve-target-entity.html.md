---
title: Symfony2ではRelationshipsにAbstract classやInterfaceが指定できる
date: 2013-12-19
tags: PHP, Symfony2
---

Doctrine2の`OneToMany`や`ManyToMany`の`targetEntity`にはAbstract classやInterfaceを指定することができる。[普通にリファレンスには書いてある](http://symfony.com/doc/current/cookbook/doctrine/resolve_target_entity.html)のだが、日本語の情報は無さそうだったので紹介。

CoreBundle:

```php
<?php
namespace Acme\CoreBundle\Entity;

use Doctrine\ORM\Mapping as ORM;
use Acme\BlogBundle\Model\Article as BaseArticle;
use Acme\BlogBundle\Model\Comment as BaseComment;

/**
 * @ORM\Entity
 * @ORM\Table(name="articles")
 */
class Article extends BaseArticle
{}

/**
 * @ORM\Entity
 * @ORM\Table(name="comments")
 */
class Comment extends BaseComment
{}
```

BlogBundle:

```php
<?php
namespace Acme\BlogBundle\Model;

use Doctrine\ORM\Mapping as ORM;
use Doctrine\Common\Collections\ArrayCollection;

interface ArticleInterface {}
interface CommentInterface {}

abstract class Article implements ArticleInterface
{
    /**
     * @ORM\OneToMany(targetEntity="Acme\BlogBundle\Model\CommentInterface", mappedBy="article")
     * @var ArrayCollection
     */
    protected $comments;
}

abstract class Comment implements CommentInterface
{
    /**
     * @ORM\ManyToOne(targetEntity="Acme\BlogBundle\Model\ArticleInterface")
     * @ORM\JoinColumn(name="article_id", referencedColumnName="id")
     * @var ArticleInterface
     */
    protected $article;
}
```

app/config/config.yml でInterface（またはAbstract class）と実装したクラスをマッピングする:

```yaml
doctrine:
    orm:
        resolve_target_entities:
            Acme\BlogBundle\Model\ArticleInterface: Acme\CoreBundle\Entity\Article
            Acme\BlogBundle\Model\CommentInterface: Acme\CoreBundle\Entity\Comment
```

使いこなせば抽象度の高い汎用的なBundleを作ることができそうですね。
