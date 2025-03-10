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

## 注意事項

- DB コメントを表示するには、PostgreSQL データベースにコメントが設定されている必要があります
- 日本語フォントが正しくインストールされていることを確認してください
- 生成された ER 図は、指定した出力ディレクトリに保存されます

## ライセンス

Apache License 2.0
