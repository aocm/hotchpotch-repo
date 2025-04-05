# localstack-deploy-with-awscli
## 前提
- Windows環境
- Dockerが利用可能（ホストがdockerコマンドを利用可能）

## Powershellでlocalstackに作成
### DynamoDBテーブルの作成
```
aws dynamodb create-table --table-name my-table --attribute-definitions AttributeName=id,AttributeType=S --key-schema AttributeName=id,KeyType=HASH --billing-mode PAY_PER_REQUEST --endpoint-url http://localhost:4566
```

### S3バケットの作成
```
aws s3 mb s3://my-bucket --endpoint-url http://localhost:4566
```

### Lambda関数の作成
まず、Lambda関数のコードをlambda_function.pyとして保存します。

```js
exports.handler = async (event) => {
    return {
        statusCode: 200,
        body: 'Hello from Lambda!'
    };
};
```

次に、Lambda関数を作成します。
zipだけwslでやっても問題ないです。
```
zip function.zip index.js
aws lambda create-function --function-name my-function --runtime nodejs22.x --handler index.handler --zip-file fileb://function.zip --role arn:aws:iam::000000000000:role/lambda-role --endpoint-url http://localhost:4566
```

### api gateway
```powershell
aws apigateway create-rest-api --name my-api --endpoint-url http://localhost:4566

$API_ID=aws apigateway get-rest-apis --endpoint-url http://localhost:4566 | jq -r '.items[0].id'
$RESOURCE_ID= aws apigateway create-resource --rest-api-id $API_ID --parent-id $(aws apigateway get-resources --rest-api-id $API_ID --endpoint-url http://localhost:4566 | jq -r '.items[0].id') --path-part my-resource --endpoint-url http://localhost:4566 | jq -r '.id'

aws apigateway put-method --rest-api-id $API_ID --resource-id $RESOURCE_ID --http-method GET --authorization-type NONE --endpoint-url http://localhost:4566

$LAMBDA_F = aws lambda get-function --functi$on-name my-function --endpoint-url http://localhost:4566 | jq -r '.Configuration.FunctionArn'

aws apigateway put-integration --rest-api-id $API_ID --resource-id $RESOURCE_ID --http-method GET --type AWS_PROXY --integration-http-method POST --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/$LAMBDA_F/invocations --endpoint-url http://localhost:4566

aws apigateway create-deployment --rest-api-id $API_ID --stage-name dev --endpoint-url http://localhost:4566
```

### 確認
$API_IDがｘｘｘｘｘｘだった場合

http://localhost:4566/restapis/ｘｘｘｘｘｘ/dev/_user_request_/my-resource

