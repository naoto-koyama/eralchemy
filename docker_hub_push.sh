#!/bin/bash

# Docker Hubのユーザー名
DOCKER_HUB_USERNAME="naotokoyama324"
# イメージ名
IMAGE_NAME="eralchemy"
# タグ
TAG="latest"

# イメージをビルド
echo "イメージをビルド中..."
docker build -t ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:${TAG} -f Dockerfile.hub .

# Docker Hubにログイン
echo "Docker Hubにログイン中..."
docker login

# イメージをプッシュ
echo "イメージをプッシュ中..."
docker push ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:${TAG}

echo "完了しました。以下のコマンドでイメージを使用できます："
echo "docker run --rm -v \$(pwd):/app ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:${TAG} -i \"postgresql://ユーザー名:パスワード@ホスト:ポート/データベース名\" -o erd.pdf"
echo "DBコメント付きのER図を生成する場合は、--use-commentsオプションを追加してください。" 