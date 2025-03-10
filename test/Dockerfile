FROM python:3.9-slim

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    postgresql-client \
    graphviz \
    gcc \
    python3-dev \
    libpq-dev \
    libgraphviz-dev \
    pkg-config \
    fonts-ipafont \
    fonts-ipaexfont \
    locales \
    && rm -rf /var/lib/apt/lists/*

# ロケールを設定
RUN sed -i -e 's/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8

# eralchemyをインストール
COPY . /app
WORKDIR /app
RUN pip install -e .
RUN pip install psycopg2 pygraphviz

# 出力ディレクトリを作成
RUN mkdir -p /app/output

# テストスクリプトをコピー
COPY test/test_eralchemy.sh /app/test_eralchemy.sh
RUN chmod +x /app/test_eralchemy.sh

# コンテナ起動時にテストスクリプトを実行
CMD ["/app/test_eralchemy.sh"] 