-- テーブルの作成
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id),
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- テーブルコメントの追加
COMMENT ON TABLE users IS 'ユーザー情報を管理するテーブル';
COMMENT ON TABLE products IS '商品情報を管理するテーブル';
COMMENT ON TABLE orders IS '注文情報を管理するテーブル';
COMMENT ON TABLE order_items IS '注文明細を管理するテーブル';

-- カラムコメントの追加
COMMENT ON COLUMN users.id IS 'ユーザーID';
COMMENT ON COLUMN users.username IS 'ユーザー名';
COMMENT ON COLUMN users.email IS 'メールアドレス';
COMMENT ON COLUMN users.password_hash IS 'パスワードハッシュ';
COMMENT ON COLUMN users.created_at IS '作成日時';
COMMENT ON COLUMN users.updated_at IS '更新日時';

COMMENT ON COLUMN products.id IS '商品ID';
COMMENT ON COLUMN products.name IS '商品名';
COMMENT ON COLUMN products.description IS '商品説明';
COMMENT ON COLUMN products.price IS '価格';
COMMENT ON COLUMN products.stock_quantity IS '在庫数';
COMMENT ON COLUMN products.created_at IS '作成日時';
COMMENT ON COLUMN products.updated_at IS '更新日時';

COMMENT ON COLUMN orders.id IS '注文ID';
COMMENT ON COLUMN orders.user_id IS 'ユーザーID';
COMMENT ON COLUMN orders.total_amount IS '合計金額';
COMMENT ON COLUMN orders.status IS '注文ステータス';
COMMENT ON COLUMN orders.created_at IS '作成日時';
COMMENT ON COLUMN orders.updated_at IS '更新日時';

COMMENT ON COLUMN order_items.id IS '注文明細ID';
COMMENT ON COLUMN order_items.order_id IS '注文ID';
COMMENT ON COLUMN order_items.product_id IS '商品ID';
COMMENT ON COLUMN order_items.quantity IS '数量';
COMMENT ON COLUMN order_items.price IS '価格';
COMMENT ON COLUMN order_items.created_at IS '作成日時';
COMMENT ON COLUMN order_items.updated_at IS '更新日時'; 