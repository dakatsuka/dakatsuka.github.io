---
title: Kotlin + Gradleで別パッケージの src/test/resources を参照する方法
slug: kotlin-src-test
date: 2023-05-06T17:30:00+09:00
tags: [Kotlin]
categories: [Programming]
---

Kotlinでテストを書くときに、別パッケージの src/test/resources を参照したいケースがある。たとえばインフラストラクチャ層のテストリソースを別のサブプロジェクトのテストから参照したい場合は以下のようにすると良い。

```kotlin
project("infrastructure") {
    dependencies {
        runtimeOnly("mysql:mysql-connector-java:8.0.32")
        implementation("org.mybatis.spring.boot:mybatis-spring-boot-starter:3.0.1")
        testImplementation("org.mybatis.spring.boot:mybatis-spring-boot-starter-test:3.0.1")
    }
}

project("e2e") {
    // infrastructure/src/test/resources を参照できるようにする
    val infrastructureTests: SourceSetOutput = project(":infrastructure").sourceSets["test"].output

    dependencies {
        implementation(project(":infrastructure"))
        testImplementation(infrastructureTests)
    }
}
```