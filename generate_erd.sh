#!/bin/bash

# 環境変数はDockerコンテナから設定済み

# PostgreSQLの接続情報を環境変数から取得
DB_HOST=${POSTGRES_HOST:-db}
DB_USER=${DATABASE_USER:-root}
DB_PASS=${DATABASE_PASSWORD:-postgres}
DB_NAME=${DATABASE_NAME:-postgres}

# 出力ファイル名を設定
OUTPUT_DIR="/app/output"
OUTPUT_FILE_NORMAL="${OUTPUT_DIR}/erd_normal.pdf"
OUTPUT_FILE_COMMENTS="${OUTPUT_DIR}/erd_comments.pdf"

# 出力ディレクトリが存在しない場合は作成
mkdir -p "${OUTPUT_DIR}"

# モードの選択（デフォルトは列名）
USE_COMMENTS=${USE_COMMENTS:-false}

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

# コマンドライン引数からモードを取得
if [ "$1" == "--use-comments" ]; then
  USE_COMMENTS=true
fi

# ERDを生成
if [ "$USE_COMMENTS" = true ]; then
  echo "コメント付きのERDを生成中..."
  OUTPUT_FILE="${OUTPUT_FILE_COMMENTS}"
  COMMENT_OPTION="--use-comments"
else
  echo "通常のERDを生成中..."
  OUTPUT_FILE="${OUTPUT_FILE_NORMAL}"
  COMMENT_OPTION=""
fi

# ERDを生成
eralchemy -i "postgresql://${DB_USER}:${DB_PASS}@${DB_HOST}:5432/${DB_NAME}" -o "${OUTPUT_FILE}" ${COMMENT_OPTION}

echo "ERDが生成されました: ${OUTPUT_FILE}"
echo "完了しました。" 