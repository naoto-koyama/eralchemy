#!/bin/bash

# 環境変数はDockerコンテナから設定済み

# PostgreSQLの接続情報を環境変数から取得
DB_HOST=${POSTGRES_HOST:-db}
DB_USER=${DATABASE_USER:-root}
DB_PASS=${DATABASE_PASSWORD:-postgres}
DB_NAME=${DATABASE_NAME:-postgres}

# 出力ファイル名を設定
OUTPUT_FILE_NORMAL="/app/output/erd_normal.pdf"
OUTPUT_FILE_COMMENTS="/app/output/erd_comments.pdf"

# PostgreSQL接続の最大試行回数を設定
MAX_TRIES=30
TRIES=0

# PostgreSQLが起動するまで待機（タイムアウト付き）
while [ $TRIES -lt $MAX_TRIES ]; do
  if PGPASSWORD=$DB_PASS psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c '\q' 2>/dev/null; then
    echo "Successfully connected to PostgreSQL"
    break
  fi
  TRIES=$((TRIES+1))
  echo "Waiting for PostgreSQL to start... (Attempt $TRIES of $MAX_TRIES)"
  sleep 1
done

if [ $TRIES -eq $MAX_TRIES ]; then
  echo "Error: Could not connect to PostgreSQL after $MAX_TRIES attempts"
  exit 1
fi

# 通常のERDを生成
echo "通常のERDを生成中..."
eralchemy -i "postgresql://${DB_USER}:${DB_PASS}@${DB_HOST}:5432/${DB_NAME}" -o "${OUTPUT_FILE_NORMAL}"
echo "通常のERDが生成されました: ${OUTPUT_FILE_NORMAL}"

# コメント付きのERDを生成
echo "コメント付きのERDを生成中..."
eralchemy -i "postgresql://${DB_USER}:${DB_PASS}@${DB_HOST}:5432/${DB_NAME}" -o "${OUTPUT_FILE_COMMENTS}" --use-comments
echo "コメント付きのERDが生成されました: ${OUTPUT_FILE_COMMENTS}"

echo "完了しました。" 