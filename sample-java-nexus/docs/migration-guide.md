# 旧式 jar 直参照 Gradle プロジェクト移行ガイド

## よくある問題構成

古い Java プロジェクトでは、外部ライブラリや社内ライブラリの JAR を
ソースツリー内に置き、`files(...)` や `fileTree(...)` で直接参照していることがあります。

典型例:

```groovy
dependencies {
    implementation files('lib/legacy-a.jar')
    implementation fileTree(dir: 'lib', include: ['*.jar'])
}
```

この構成は、更新履歴の追跡、CI 再現性、依存の再利用、バージョン管理を難しくします。

## 目指す状態

再利用する JAR は Nexus のような repository manager に集約し、
Gradle からは Maven 座標で取得する構成へ移します。

目標形は次のとおりです。

```groovy
repositories {
    maven {
        url = uri('http://nexus:8081/repository/legacy-maven-hosted/')
        allowInsecureProtocol = true
    }
}

dependencies {
    implementation 'com.company.legacy:legacy-a:1.2.3'
}
```

## 移行手順

1. リポジトリ内に同梱されている JAR を棚卸しします。
2. 各 JAR に対して `groupId`、`artifactId`、`version` を決めます。
3. それらの JAR を Nexus の hosted repository に登録します。
4. `files(...)` や `fileTree(...)` を Maven 座標指定へ置き換えます。
5. ビルドと実行が repository 経由の依存解決だけで成立することを確認します。
6. 自作アプリや自作ライブラリの JAR も必要に応じて Nexus に publish します。
7. 移行後の運用手順を文書化し、再びローカル JAR 直参照に戻らないようにします。

## このサンプルとの対応関係

- `vendor/legacy-greeter`: `lib/` に置かれていた想定の擬似レガシー JAR
- ルートの `build.gradle`: Nexus から依存 JAR を取得する設定
- `scripts/publish-legacy-lib.sh`: レガシー JAR を Nexus に登録する例
- `scripts/publish-app.sh`: アプリ本体の JAR を Nexus に登録する例

## 実運用での注意

- ローカル検証以外では HTTPS を使ってください。
- publish 用アカウントは `admin` ではなく専用ユーザーに分離してください。
- 歴史的事情でソースがない JAR でも、バイナリだけ Nexus に登録して座標管理は可能です。
- repository URL や認証情報は、環境変数や Gradle property で外出ししてください。
- 移行完了後は、Git 管理されている不要な JAR を削除してください。
