---
title: Symfony2でFunctional Testを快適に行うには
date: 2013-12-05
tags: PHP, Symfony2
---

## 前置き

Symfony2を構成するサービスはほぼDIコンテナの上に乗っているので、ドメインとデータベース、フレームワークがそれぞれ疎結合になっています。そのため、ドメインのテストを行う際はフレームワークの読み込みやデータベースに接続する必要はありません。依存部分はモックに置き換えてしまえば良いわけです。

とはいえ、コントローラやサービスは実際にデータベースに接続してテストを行っておきたいのが人情。モックで置き換えているユニットテストだと動いたけど、結合してみたら動かない…なんてよくある話ですから。

そしてSymfony2にはWebTestCaseというテスト用のクラスが用意されていて（中身はPHPUnitです）、これを継承したクラスを作ることでSymfony2が読み込まれた状態でテストをすることが可能になります。主にリクエストやルーティング、ビューのテストに使用するのが目的のようですが、ドメインの結合テストにも使うことが出来ます。

## テストデータの投入

[Doctrine Data Fixtures Extension](https://github.com/doctrine/data-fixtures)というライブラリを使えば初期データをデータベースに投入することが出来ます。ただ、これは好みの問題かもしれませんが、自分はあまり使い勝手が良いとは思えませんでした。ただデータを投入するだけなら良いのですが、テストで使おうと思うとEntityを毎回findしてこないといけなくて辛い感じがします。`getOrder()`メソッドで読み込み順を数値で設定するのもどうなの的な。

なので私は[BlueprintBundle](https://github.com/dakatsuka/BlueprintBundle)という代替ライブラリを作ってそちらを使っています。データベースに保存した上でエンティティを取得出来るので中々便利に使えています。自画自賛。

```php
<?php

Blueprint::register('post', 'Acme\BlogBundle\Entity\Post', function($post, $blueprint) {
    $post->setTitle('Title' . $blueprint->sequence());
    $post->setBody('BodyBodyBody');
});

$blueprint = static::$container->get('dakatsuka.blueprint');

$post1 = $blueprint->create('post');
$post2 = $blueprint->create('post');
$post3 = $blueprint->build('post'); // DBには保存しない
```

## データベースのお掃除

ひとつ前のテストケースの影響を受けないようにするために、テスト毎にデータベースを掃除する必要があります。前述のDoctrine Data Fixtures Extensionの`ORMPurger`クラスを使うことで実現出来ます。

ちなみに`ORMPurger`は2種類のモードがあって`PURGE_MODE_DELETE`か`PURGE_MODE_TRUNCATE`を選ぶことができます。トランザクションで制御したい場合は、`ORMPurger`は使わずにsetUpでトランザクションを開始してtearDownでロールバックする必要があります。

```php
<?php

abstract class FunctionalTest extends WebTestCase
{
    /**
     * @var \Symfony\Component\HttpKernel\Kernel
     */
    static protected $kernel;

    /**
     * @var \Symfony\Component\DependencyInjection\Container
     */
    static protected $container;

    protected function setUp()
    {
        parent::setUp();

        static::$kernel = static::createKernel();
        static::$kernel->boot();
        static::$container = static::$kernel->getContainer();

        static::$container->get('doctrine')->getManager('default')->beginTransaction();
    }

    protected function tearDown()
    {
        parent::tearDown();

        static::$container->get('doctrine')->getManager('default')->rollback();

        foreach (static::$container->get('doctrine')->getConnections() as $connection) {
            $connection->close();
        }
    }
}
```

テストの数が多くなってくるとDELETEもTRUNCATEも遅くてつらいので、私はトランザクションを使ってテストケース毎にロールバックする方法を取っています。今のところ特に困ったことにはなっていませんので、テストが遅くて困ってる人は試してみる価値はあると思います。

## 最後

Symfony2、あまり情報がなくて自分の方法が正しいのか不安になることが多々。間違っていたりもっと良い方法があったら是非教えてください！
