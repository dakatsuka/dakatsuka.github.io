---
title: Monologのログ出力先をFluentdに変更してみた
date: 2013-10-18
tags: PHP,Monolog
---
Symfony2にも採用されているMonologは、HandlerやFormatterを差し替えることでログの出力先やフォーマットを自由に変更することが出来ます。PSR3に準拠しているライブラリですので、今後デファクトスタンダードになっていく気がします。

デフォルトだとStreamHandlerを使って出力されますが、Handlerを自作してFluentdに出力されるように変更してみます。バックエンドにはfluent-logger-phpを利用しました。

MonologのHandlerはAbstractProcessingHandlerを継承して作ります。

```php
<?php
namespace Acme\Handler;
 
use Fluent\Logger\FluentLogger;
use Monolog\Handler\AbstractProcessingHandler;
use Monolog\Logger;
 
class FluentHandler extends AbstractProcessingHandler
{
    protected $logger;
 
    public function __construct(
        $logger = null,
        $host   = FluentLogger::DEFAULT_ADDRESS,
        $port   = FluentLogger::DEFAULT_LISTEN_PORT,
        $level  = Logger::DEBUG,
        $bubble = true
    )
    {
        parent::__construct($level, $bubble);
 
        if (is_null($logger)) {
            $logger = new FluentLogger($host, $port);
        }
 
        $this->logger = $logger;
    }
 
    public function write(array $record)
    {
        $tag  = $record['channel'] . '.' . $record['message'];
        $data = $record['context'];
        $data['level'] = Logger::getLevelName($record['level']);
 
        $this->logger->post($tag, $data);
    }
}
```

使い方

```php
<?php
use Acme\Handler\FluentHandler
use Monolog\Logger;
 
$logger = new Logger('test');
$logger->pushHandler(new FluentHandler());
 
$logger->debug('example.monolog', array('foo' => 'bar'));
$logger->info('example.fluentd', array('fizz' => 'buzz'));
```

利用しやすいようにGitHubとPackagistに公開しておきました。

* [dakatsuka/MonologFluentHandler](https://github.com/dakatsuka/MonologFluentHandler)
* [dakatsuka/monolog-fluent-handler](https://packagist.org/packages/dakatsuka/monolog-fluent-handler)
