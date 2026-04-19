# sample-java-nexus

古い Java プロジェクトでありがちな「`build.gradle` からローカル JAR を直接読む」構成を、
Nexus 管理へ移行するための検証用サンプルです。

このサンプルには、次の要素が含まれます。

- Nexus に登録するサンプルライブラリ `legacy-greeter`
- そのライブラリを Nexus から取得して動く Java アプリ
- 実行可能 JAR を Nexus に再登録する publish 設定
- WSL + Docker Compose で再現できる検証環境

## 構成図

```text
+---------------------------------------------------------------+
| WSL                                                           |
|                                                               |
|  sample-java-nexus/                                           |
|  |                                                            |
|  |  docker compose up -d                                      |
|  v                                                            |
|                                                               |
|  +---------------------+        HTTP :8081        +---------+ |
|  | jdk container       | <----------------------> | Nexus 3 | |
|  | Gradle / JDK 17     |                          |         | |
|  +---------------------+                          +---------+ |
|      |                        公開/取得                ^      |
|      |                                                |      |
|      | publish-legacy-lib.sh                          |      |
|      +--> com.example.legacy:legacy-greeter:1.0.0 ---+      |
|      |                                                       |
|      | run-app.sh                                            |
|      +--> build.gradle で dependency 解決 -------------------+ 
|      |                                                       |
|      | publish-app.sh                                        |
|      +--> com.example.app:sample-java-nexus-app:1.0.0 ------+ 
|                                                               |
+---------------------------------------------------------------+
```

## ディレクトリ構成

- `docker-compose.yml`: Nexus と JDK コンテナを起動する構成
- `docker/jdk/Dockerfile`: Gradle を利用できる JDK イメージ
- `vendor/legacy-greeter`: 擬似レガシー JAR のサンプル実装
- `src/main/java`: Nexus 上の JAR を利用するアプリ本体
- `scripts/`: 起動、初期化、publish、実行の補助スクリプト
- `docs/migration-guide.md`: 旧式プロジェクトの移行ガイド

## クイックスタート

このディレクトリで、WSL からコマンドを実行してください。

1. 検証環境を起動します。

    ```bash
    docker compose up -d
    ```

2. Nexus の起動待ち、管理者パスワード設定、EULA 同意、サンプル用 hosted repository 作成を行います。

    ```bash
    bash scripts/bootstrap-nexus.sh
    ```

3. サンプルのレガシー JAR を Nexus に登録します。

    ```bash
    bash scripts/publish-legacy-lib.sh
    ```

4. アプリを起動します。依存 JAR は Nexus から取得されます。

    ```bash
    bash scripts/run-app.sh
    ```

5. アプリの JAR も Nexus に登録します。

    ```bash
    bash scripts/publish-app.sh
    ```

## Nexus の確認先

- UI: `http://localhost:8081`
- サンプル用 repository: `http://localhost:8081/repository/legacy-maven-hosted/`

このサンプルでは、簡便のため bootstrap 後の管理者アカウントとして
`admin` / `admin123` を使用します。

## Nexus GUI での再現手順

GUI でこのサンプルと同じ repository を作る場合は、次の順で操作します。

1. `Administration`
2. `Repositories`
3. `Create repository`
4. `maven2 (hosted)` を選択
5. 以下の値を入力して作成

入力値の対応は次のとおりです。

- 種別: `maven2 (hosted)`
- Name: `legacy-maven-hosted`
- Online: `ON`
- Blob store: `default`
- Strict Content Type Validation: `ON`
- Deployment policy / Write policy: `ALLOW`
- Version policy: `MIXED`
- Layout policy: `STRICT`
- Content disposition: `ATTACHMENT`
- Proprietary Components: `ON`

補足:

- このサンプルで自動作成している独自 repository は `legacy-maven-hosted` の 1 つだけです。
- `legacy-greeter` と `sample-java-nexus-app` はどちらもこの repository に publish します。
- アプリ側の `build.gradle` も、同じ `legacy-maven-hosted` を参照して依存解決します。

## 登録される Maven 座標

サンプルライブラリ:

```text
com.example.legacy:legacy-greeter:1.0.0
```

サンプルアプリ:

```text
com.example.app:sample-java-nexus-app:1.0.0
```

## JAR 依存関係図

```text
+---------------------------------------------------------------+
| アプリ実行時の依存関係                                        |
+---------------------------------------------------------------+

com.example.app:sample-java-nexus-app:1.0.0
                |
                +-- depends on -->
                       com.example.legacy:legacy-greeter:1.0.0


+---------------------------------------------------------------+
| Nexus 上での見え方                                            |
+---------------------------------------------------------------+

legacy-maven-hosted
|
+-- com/example/app/sample-java-nexus-app/1.0.0/
|   `-- sample-java-nexus-app-1.0.0.jar
|
`-- com/example/legacy/legacy-greeter/1.0.0/
    `-- legacy-greeter-1.0.0.jar
```

## 旧式構成からの置き換えイメージ

古い構成では、次のようにローカル JAR を直接参照しがちです。

```groovy
dependencies {
    implementation files('lib/legacy-greeter.jar')
}
```

このサンプルでは、これを Maven repository + 座標指定へ置き換えます。

```groovy
repositories {
    maven {
        url = uri('http://nexus:8081/repository/legacy-maven-hosted/')
        allowInsecureProtocol = true
    }
}

dependencies {
    implementation 'com.example.legacy:legacy-greeter:1.0.0'
}
```

## 片付け

コンテナだけ停止する場合:

```bash
docker compose down
```

Nexus のデータボリュームも含めて削除する場合:

```bash
docker compose down -v
```
