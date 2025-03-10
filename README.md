[![license](https://img.shields.io/badge/License-Apache%202.0-yellow?logo=opensourceinitiative&logoColor=white)](LICENSE)
[![PyPI - Version](https://img.shields.io/pypi/v/eralchemy?logo=pypi&logoColor=white)](https://pypi.org/project/ERAlchemy/)
[![PyPI Downloads](https://img.shields.io/pypi/dm/eralchemy?logo=pypi&logoColor=white)](https://pypi.org/project/eralchemy/)

# ERAlchemy - DB コメント表示機能付き ER 図生成ツール

このリポジトリは、PostgreSQL データベースから ER 図を生成し、DB コメントを表示する機能を追加した eralchemy のフォークです。

## 特徴

- PostgreSQL データベースから ER 図を自動生成
- データベースコメントを表示する機能
- 日本語フォントのサポート
- Docker Hub からの簡単な実行

## 使用方法

### Docker Hub を使用した簡単な実行方法（推奨）

```bash
# 通常のER図を生成
docker run --rm -v $(pwd):/app naotokoyama324/eralchemy -i "postgresql://ユーザー名:パスワード@ホスト:ポート/データベース名" -o /app/erd.pdf

# DBコメント付きのER図を生成
docker run --rm -v $(pwd):/app naotokoyama324/eralchemy -i "postgresql://ユーザー名:パスワード@ホスト:ポート/データベース名" -o /app/erd_comments.pdf --use-comments
```

#### 例（MacOS）

```bash
docker run --rm -v $(pwd):/app naotokoyama324/eralchemy -i "postgresql://postgres:postgres@host.docker.internal:5432/postgres" -o /app/erd.pdf
```

#### 例（Linux）

```bash
docker run --rm -v $(pwd):/app naotokoyama324/eralchemy -i "postgresql://postgres:postgres@172.17.0.1:5432/postgres" -o /app/erd.pdf
```

#### トラブルシューティング

もし上記のコマンドでエラーが発生する場合は、以下のように`--entrypoint`オプションを使用してください：

```bash
docker run --rm -v $(pwd):/app --entrypoint eralchemy naotokoyama324/eralchemy -i "postgresql://ユーザー名:パスワード@ホスト:ポート/データベース名" -o /app/erd_comments.pdf --use-comments
```

例：

```bash
docker run --rm -v $(pwd):/app --entrypoint eralchemy naotokoyama324/eralchemy -i "postgresql://postgres:postgres@host.docker.internal:5432/postgres" -o /app/erd_comments.pdf --use-comments
```

### 直接インストールして使用する方法

#### インストール

```bash
# GitHubからリポジトリをクローン
git clone https://github.com/naoto-koyama/eralchemy.git
cd eralchemy

# インストール
pip install -e .
pip install pygraphviz  # または pip install graphviz

# 日本語フォントのインストール（必要な場合）
# Debian/Ubuntu
apt install fonts-ipafont fonts-ipaexfont locales
sed -i -e 's/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen && locale-gen

# macOS
brew install font-ipa
```

#### コマンドライン使用例

```bash
# 通常のER図を生成
eralchemy -i "postgresql://ユーザー名:パスワード@ホスト:ポート/データベース名" -o erd.pdf

# DBコメント付きのER図を生成
eralchemy -i "postgresql://ユーザー名:パスワード@ホスト:ポート/データベース名" -o erd_comments.pdf --use-comments

# 特定のスキーマのみを対象にする
eralchemy -i "postgresql://ユーザー名:パスワード@ホスト:ポート/データベース名" -o erd.pdf --use-comments -s "スキーマ名"

# 特定のテーブルを除外する
eralchemy -i "postgresql://ユーザー名:パスワード@ホスト:ポート/データベース名" -o erd.pdf --use-comments --exclude-tables テーブル1 テーブル2
```

#### Python から使用する例

```python
from eralchemy import render_er

# 通常のER図を生成
render_er("postgresql://ユーザー名:パスワード@ホスト:ポート/データベース名", 'erd.png')

# DBコメントを表示したER図を生成
render_er("postgresql://ユーザー名:パスワード@ホスト:ポート/データベース名", 'erd_comments.png', use_comments=True)
```

## 注意事項

- 出力ファイルのパスは `/app/` から始まるパスを指定してください（例：`-o /app/erd.pdf`）
- ホスト名には、Docker コンテナからアクセス可能なホスト名または IP アドレスを指定してください
  - ローカルホストの場合は、MacOS では`host.docker.internal`、Linux では`172.17.0.1`などを使用
- DB コメントを表示するには、PostgreSQL データベースにコメントが設定されている必要があります
- 日本語フォントが正しくインストールされていることを確認してください

## ライセンス

Apache License 2.0
