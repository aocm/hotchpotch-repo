FROM node:22

WORKDIR /app

COPY .output .output

# コンテナのポートを指定
EXPOSE 3000

# アプリケーションの起動コマンド
CMD ["node", ".output/server/index.mjs"]