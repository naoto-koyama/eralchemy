[![license](https://img.shields.io/badge/License-Apache%202.0-yellow?logo=opensourceinitiative&logoColor=white)](LICENSE)
[![PyPI - Version](https://img.shields.io/pypi/v/eralchemy?logo=pypi&logoColor=white)](https://pypi.org/project/ERAlchemy/)
[![PyPI Downloads](https://img.shields.io/pypi/dm/eralchemy?logo=pypi&logoColor=white)](https://pypi.org/project/eralchemy/)
[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/eralchemy/eralchemy/unit.yaml?logo=github&logoColor=white)](https://github.com/eralchemy/eralchemy/actions/workflows/unit.yaml)
[![Codecov](https://img.shields.io/codecov/c/github/eralchemy/eralchemy?logo=codecov&logoColor=white&token=gSfKRZVvAh)](https://app.codecov.io/gh/eralchemy/eralchemy/tree/main)

# ERAlchemy - DB コメント表示機能付き ER 図生成ツール

このリポジトリは、PostgreSQL データベースから ER 図を生成し、DB コメントを表示する機能を追加した eralchemy のフォークです。

## インストール方法

### 基本インストール

```bash
# GitHubからリポジトリをクローン
git clone https://github.com/naoto-koyama/eralchemy.git
cd eralchemy

# インストール
pip install -e .

# グラフ生成に必要なライブラリをインストール
pip install pygraphviz
# または
pip install graphviz
```

### 日本語フォントのインストール

日本語の DB コメントを正しく表示するには、日本語フォントが必要です。

Debian/Ubuntu の場合:

```bash
apt install fonts-ipafont fonts-ipaexfont locales
# ロケールの設定
sed -i -e 's/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
```

macOS の場合:

```bash
brew install font-ipa
```

## 使用方法

### コマンドラインから使用する

#### 通常の ER 図を生成する場合

```bash
eralchemy -i "postgresql://ユーザー名:パスワード@ホスト:ポート/データベース名" -o erd_normal.pdf
```

#### DB コメントを表示した ER 図を生成する場合

```bash
eralchemy -i "postgresql://ユーザー名:パスワード@ホスト:ポート/データベース名" -o erd_comments.pdf --use-comments
```

#### 特定のスキーマのみを対象にする場合

```bash
eralchemy -i "postgresql://ユーザー名:パスワード@ホスト:ポート/データベース名" -o erd.pdf --use-comments -s "スキーマ名"
```

#### 特定のテーブルを除外する場合

```bash
eralchemy -i "postgresql://ユーザー名:パスワード@ホスト:ポート/データベース名" -o erd.pdf --use-comments --exclude-tables テーブル1 テーブル2
```

### Python から使用する

```python
from eralchemy import render_er

# 通常のER図を生成
render_er("postgresql://ユーザー名:パスワード@ホスト:ポート/データベース名", 'erd_normal.png')

# DBコメントを表示したER図を生成
render_er("postgresql://ユーザー名:パスワード@ホスト:ポート/データベース名", 'erd_comments.png', use_comments=True)
```

## Docker を使用する方法

このリポジトリには、Docker を使用して ER 図を生成するためのスクリプトが含まれています。

### 準備

```bash
# リポジトリをクローン
git clone https://github.com/naoto-koyama/eralchemy.git
cd eralchemy

# 出力ディレクトリを作成
mkdir -p output
```

### Docker Compose を使用する場合

```bash
# PostgreSQLコンテナを起動
docker-compose up -d db

# eralchemyコンテナをビルドして実行
docker build -t eralchemy .

# 通常のER図を生成
docker run --network eralchemy_default \
  -e POSTGRES_HOST=db \
  -e DATABASE_USER=root \
  -e DATABASE_PASSWORD=postgres \
  -e DATABASE_NAME=postgres \
  -v $(pwd)/output:/app/output \
  eralchemy ./generate_erd.sh

# DBコメントを表示したER図を生成
docker run --network eralchemy_default \
  -e POSTGRES_HOST=db \
  -e DATABASE_USER=root \
  -e DATABASE_PASSWORD=postgres \
  -e DATABASE_NAME=postgres \
  -v $(pwd)/output:/app/output \
  eralchemy ./generate_erd.sh --use-comments
```

### 既存の Docker コンテナに組み込む場合

既存の Docker コンテナに組み込む場合は、以下のファイルを追加してください。

1. `generate_erd.sh`スクリプトをコンテナ内に配置
2. 必要なパッケージをインストール:

   ```
   apt-get update && apt-get install -y \
       postgresql-client \
       graphviz \
       gcc \
       python3-dev \
       libpq-dev \
       libgraphviz-dev \
       pkg-config \
       fonts-ipafont \
       fonts-ipaexfont \
       locales

   # ロケールの設定
   sed -i -e 's/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
   ```

3. eralchemy をインストール:
   ```
   pip install git+https://github.com/naoto-koyama/eralchemy.git
   pip install psycopg2 pygraphviz
   ```

## 既存のプロジェクトへの組み込み方法

既存のプロジェクトで ER 図生成スクリプトを使用している場合、以下の手順で DB コメント表示機能を追加できます。

### 1. Dockerfile の修正

既存の`eralchemy.Dockerfile`を以下のように修正します：

```dockerfile
FROM python:3.9

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    graphviz \
    graphviz-dev \
    libpq-dev \
    postgresql-client \
    gcc \
    python3-dev \
    libgraphviz-dev \
    pkg-config \
    fonts-ipafont \
    fonts-ipaexfont \
    locales

# ロケールを設定
RUN sed -i -e 's/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8

# 修正版eralchemyをインストール
RUN pip install git+https://github.com/naoto-koyama/eralchemy.git
RUN pip install psycopg2 pygraphviz

WORKDIR /app

COPY scripts/erd.sh /app/
RUN chmod +x /app/erd.sh

ENTRYPOINT ["/app/erd.sh"]
```

### 2. ER 図生成スクリプトの作成

`scripts/erd.sh`ファイルを以下の内容で作成します：

```bash
#!/bin/bash

# 環境変数はDockerコンテナから設定済み

# PostgreSQLの接続情報を環境変数から取得
DB_HOST=${POSTGRES_HOST:-db}
DB_USER=${DATABASE_USER:-root}
DB_PASS=${DATABASE_PASSWORD:-postgres}
DB_NAME=${DATABASE_NAME:-postgres}

# 出力ファイル名を設定
OUTPUT_DIR="/app/output"
OUTPUT_FILE_NORMAL="${OUTPUT_DIR}/erd.pdf"
OUTPUT_FILE_COMMENTS="${OUTPUT_DIR}/erd_comments.pdf"

# 出力ディレクトリが存在しない場合は作成
mkdir -p "${OUTPUT_DIR}"

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
USE_COMMENTS=${USE_COMMENTS:-false}
if [ "$1" == "--use-comments" ]; then
  USE_COMMENTS=true
fi

# 通常のER図を生成
echo "通常のER図を生成中..."
eralchemy -i "postgresql://${DB_USER}:${DB_PASS}@${DB_HOST}:5432/${DB_NAME}" -o "${OUTPUT_FILE_NORMAL}"
echo "通常のER図が生成されました: ${OUTPUT_FILE_NORMAL}"

# DBコメント付きのER図を生成
if [ "$USE_COMMENTS" = true ] || [ "$GENERATE_BOTH" = true ]; then
  echo "DBコメント付きのER図を生成中..."
  eralchemy -i "postgresql://${DB_USER}:${DB_PASS}@${DB_HOST}:5432/${DB_NAME}" -o "${OUTPUT_FILE_COMMENTS}" --use-comments
  echo "DBコメント付きのER図が生成されました: ${OUTPUT_FILE_COMMENTS}"
fi

echo "ER図の生成が完了しました。"
```

### 3. メインスクリプトの修正

`scripts/generate-erd.sh`ファイルを以下のように修正します：

```bash
#!/bin/bash

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_DIR="$(dirname "$SCRIPT_DIR")"

# ERD生成用のDockerfileのパスを設定
DOCKERFILE_PATH="${DB_DIR}/eralchemy.Dockerfile"

# コマンドライン引数を解析
USE_COMMENTS=false
GENERATE_BOTH=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --use-comments)
      USE_COMMENTS=true
      shift
      ;;
    --both)
      GENERATE_BOTH=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--use-comments] [--both]"
      exit 1
      ;;
  esac
done

# PostgreSQLコンテナが起動しているか確認
if ! docker ps | grep -q postgres_db; then
  echo "Error: PostgreSQL container (postgres_db) is not running"
  exit 1
fi

# Dockerネットワークを取得
# docker-composeのネットワーク名を取得
COMPOSE_NETWORK=$(docker network ls --filter name=postgres --format "{{.Name}}" | head -n 1)
# コンテナに接続されているネットワーク名を取得
CONTAINER_NETWORK=$(docker container inspect postgres_db -f '{{range $net, $conf := .NetworkSettings.Networks}}{{$net}}{{end}}')

# 優先順位: COMPOSE_NETWORK > CONTAINER_NETWORK > デフォルト値
if [ -n "$COMPOSE_NETWORK" ]; then
  NETWORK_NAME=$COMPOSE_NETWORK
elif [ -n "$CONTAINER_NETWORK" ]; then
  NETWORK_NAME=$CONTAINER_NETWORK
else
  # どちらも取得できない場合はデフォルトのネットワーク名を使用
  NETWORK_NAME="bridge"
  echo "Warning: Using default network 'bridge' as no specific network was found"
fi

echo "Using Docker network: ${NETWORK_NAME}"

# .envファイルから環境変数を読み込む
if [ -f "${DB_DIR}/.env" ]; then
  export $(cat "${DB_DIR}/.env" | grep -v '^#' | xargs)
fi

# Docker関連の環境変数を設定してエラーメッセージを抑制
export DOCKER_SCAN_SUGGEST=false
export DOCKER_BUILDKIT=1
export BUILDKIT_PROGRESS=plain
export DOCKER_CLI_HINTS=false

# ERD生成用のコンテナを実行
docker build -q -t erd-generator -f "${DOCKERFILE_PATH}" "${DB_DIR}" > /dev/null

# PostgreSQLホスト名を設定（コンテナ名またはサービス名）
PG_HOST="postgres_db"
# GitHub Actionsの場合はサービス名を使用
if [ -n "$GITHUB_ACTIONS" ]; then
  PG_HOST="db"
fi

# コマンドライン引数を設定
CMD_ARGS=""
if [ "$USE_COMMENTS" = true ]; then
  CMD_ARGS="--use-comments"
fi

docker run --rm \
  --network "${NETWORK_NAME}" \
  -v "${DB_DIR}:/app/output" \
  -e POSTGRES_HOST="${PG_HOST}" \
  -e DATABASE_USER="${DATABASE_USER:-root}" \
  -e DATABASE_PASSWORD="${DATABASE_PASSWORD:-postgres}" \
  -e DATABASE_NAME="${DATABASE_NAME:-postgres}" \
  -e GENERATE_BOTH="${GENERATE_BOTH}" \
  erd-generator ${CMD_ARGS} 2> >(grep -v "gcloud.auth.docker-helper")

echo "Generated ERD: ${DB_DIR}/erd.pdf"
if [ "$USE_COMMENTS" = true ] || [ "$GENERATE_BOTH" = true ]; then
  echo "Generated ERD with comments: ${DB_DIR}/erd_comments.pdf"
fi
```

### 4. 使用方法

ファイルを配置したら、以下のコマンドで ER 図を生成できます：

```bash
# 通常のER図を生成
./scripts/generate-erd.sh

# DBコメント付きのER図を生成
./scripts/generate-erd.sh --use-comments

# 両方のER図を生成
./scripts/generate-erd.sh --both
```

### 5. 注意事項

- PostgreSQL コンテナ名が`postgres_db`でない場合は、スクリプト内の`postgres_db`を実際のコンテナ名に変更してください。
- データベース名やユーザー名、パスワードは環境に合わせて調整してください。
- DB コメントを表示するには、PostgreSQL データベースにコメントが設定されている必要があります。

## 注意事項

- DB コメントを表示するには、PostgreSQL データベースにコメントが設定されている必要があります
- 日本語フォントが正しくインストールされていることを確認してください
- 生成された ER 図は、指定した出力ディレクトリに保存されます

## ライセンス

Apache License 2.0
