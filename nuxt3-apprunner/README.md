# nuxt3をapprunnerで動かす

```

## マネコン操作でecrを作成

## ログイン
aws ecr get-login-password --region ap-northeast-1 --profile myaws | docker login --username AWS --password-stdin xxxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com

## ビルド
docker build -t sample-nuxt-app .

## タグ付け
docker tag sample-nuxt-app:latest xxxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/sample-nuxt-app:latest   

## push
docker push xxxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/sample-nuxt-app:latest                

## マネコン操作
- apprunnerで新規サービス作成
- コンテナレジストリ、ECRを選択
- コンテナイメージの URI xxxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/sample-nuxt-app:latest
- ECR アクセスロール 新しいサービスロールの作成 / もともとあれば既存のでOK
- ポートだけ3000に変更

```

