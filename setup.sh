#!/bin/bash

# エラーが発生したらスクリプトを終了する
set -e

# 色付け用変数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Docker実行権限チェックと自動修正
echo -e "${YELLOW}Dockerの実行権限を確認しています...${NC}"
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}エラー: Dockerコマンドの実行権限がありません。${NC}"
    read -p "スクリプトが自動で権限を付与しますか？ (sudo usermod -aG docker \$USER を実行します) [y/N]: " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        echo "管理者パスワードを入力してください..."
        sudo usermod -aG docker $USER
        echo -e "${GREEN}ユーザーを 'docker' グループに追加しました。${NC}"
        echo -e "${RED}【重要】変更を有効にするには、ターミナルを再起動してから、もう一度このスクリリプトを実行してください。${NC}"
        exit 1
    else
        echo "処理を中断しました。"
        exit 1
    fi
fi
echo -e "${GREEN}Dockerの実行権限OK。${NC}"

echo -e "${BLUE}Laravel Docker環境セットアップを開始します...${NC}"

# .envファイルの作成 (UID/GID設定)
echo -e "${YELLOW}ステップ1: .env ファイルを作成して、ファイル権限を設定します...${NC}"
cat <<EOF > .env
UID=$(id -u)
GID=$(id -g)
EOF
echo -e "${GREEN}.env ファイル作成完了。${NC}"

# ディレクトリ構造の作成
echo -e "${YELLOW}ステップ2: 必要なディレクトリを作成しています...${NC}"
mkdir -p docker/app
mkdir -p docker/web
mkdir -p crud-app
echo -e "${GREEN}ディレクトリ作成完了。${NC}"

# Dockerfileの作成
echo -e "${YELLOW}ステップ3: docker/app/Dockerfile を作成しています...${NC}"
cat <<EOF > docker/app/Dockerfile
FROM php:8.2-fpm

ARG UID
ARG GID

RUN apt-get update && apt-get install -y \\
    git curl zip unzip libpng-dev libjpeg62-turbo-dev libfreetype6-dev \\
    libzip-dev libonig-dev libxml2-dev \\
    && docker-php-ext-configure gd --with-freetype --with-jpeg \\
    && docker-php-ext-install -j\$(nproc) gd \\
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath xml zip

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# --- [修正] GIDの衝突を解決するロジックを追加 ---
RUN EXISTING_GID_GROUP_NAME=\$(getent group \${GID} | cut -d: -f1); \\
    if [ -n "\$EXISTING_GID_GROUP_NAME" ] && [ "\$EXISTING_GID_GROUP_NAME" != "www-data" ]; then \\
        groupdel "\$EXISTING_GID_GROUP_NAME"; \\
    fi; \\
    groupmod -g \${GID} www-data; \\
    usermod -u \${UID} www-data;

CMD ["php-fpm"]
EOF
echo -e "${GREEN}docker/app/Dockerfile 作成完了。${NC}"

# Nginx設定ファイルの作成
echo -e "${YELLOW}ステップ4: docker/web/default.conf を作成しています...${NC}"
cat <<EOF > docker/web/default.conf
server {
    listen 80;
    server_name localhost;
    root /var/www/html/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        fastcgi_pass app:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
echo -e "${GREEN}docker/web/default.conf 作成完了。${NC}"

# docker-compose.ymlの作成
echo -e "${YELLOW}ステップ5: docker-compose.yml を作成しています...${NC}"
cat <<EOF > docker-compose.yml
services:
  web:
    image: nginx:1.15.6
    container_name: crud_web
    ports:
      - "8000:80"
    volumes:
      - ./crud-app:/var/www/html
      - ./docker/web/default.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - app
    networks:
      - crud_network

  app:
    build:
      context: ./docker/app
      args:
        UID: \${UID}
        GID: \${GID}
    container_name: crud_app
    volumes:
      - ./crud-app:/var/www/html
    depends_on:
      - mysql
    networks:
      - crud_network
    env_file:
      - .env

  mysql:
    image: mysql:5.7
    platform: linux/amd64
    container_name: crud_mysql
    ports:
      - "33060:3306"
    environment:
      MYSQL_DATABASE: laravel_db
      MYSQL_USER: laravel_user
      MYSQL_PASSWORD: password
      MYSQL_ROOT_PASSWORD: rootpassword
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - crud_network

networks:
  crud_network:
    driver: bridge

volumes:
  mysql_data:
EOF
echo -e "${GREEN}docker-compose.yml 作成完了。${NC}"

# Dockerコンテナのビルドと起動
echo -e "${YELLOW}ステップ6: Dockerコンテナをビルドして起動しています... (時間がかかる場合があります)${NC}"
docker-compose up -d --build
echo -e "${GREEN}Dockerコンテナの起動完了。${NC}"

# Laravelのインストール
echo -e "${YELLOW}ステップ7: Laravelをインストールしています... (crud-appディレクトリにインストールします)${NC}"
docker-compose exec app composer create-project --prefer-dist laravel/laravel . "10.*"
echo -e "${GREEN}Laravelのインストール完了。${NC}"

# Laravelのファイル権限を調整
echo -e "${YELLOW}ステップ8: Laravelの書き込み権限を調整しています...${NC}"
docker-compose exec app chmod -R 775 storage bootstrap/cache
echo -e "${GREEN}権限調整完了。${NC}"

# Laravelの初期設定
echo -e "${YELLOW}ステップ9: Laravelの初期設定を行っています... (.env作成とAPP_KEY生成)${NC}"
docker-compose exec app cp .env.example .env
docker-compose exec app php artisan key:generate
echo -e "${GREEN}Laravelの初期設定完了。${NC}"

# .envファイルのデータベース接続情報を更新
echo -e "${YELLOW}ステップ10: .envファイルのデータベース接続情報を更新しています...${NC}"
docker-compose exec app bash -c "\
    sed -i 's/^DB_HOST=.*/DB_HOST=mysql/' .env && \
    sed -i 's/^DB_PORT=.*/DB_PORT=3306/' .env && \
    sed -i 's/^DB_DATABASE=.*/DB_DATABASE=laravel_db/' .env && \
    sed -i 's/^DB_USERNAME=.*/DB_USERNAME=laravel_user/' .env && \
    sed -i 's/^DB_PASSWORD=.*/DB_PASSWORD=password/' .env"
echo -e "${GREEN}.envファイルのデータベース接続情報更新完了。${NC}"

# Nginxコンテナの再起動
echo -e "${YELLOW}ステップ11: Nginxコンテナを再起動しています...${NC}"
docker-compose restart web
echo -e "${GREEN}Nginxコンテナの再起動完了。${NC}"

echo -e "${GREEN}全てのセットアップ処理が完了しました！${NC}"
echo -e "ブラウザで ${BLUE}http://localhost:8000${NC} にアクセスしてLaravelの初期画面が表示されるか確認してください。"
echo -e "コンテナの状態を確認するには、 ${YELLOW}docker-compose ps${NC} を実行してください。"
echo -e "開発を停止するには ${YELLOW}docker-compose stop${NC} を実行してください。"

exit 0
