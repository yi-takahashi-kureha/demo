# Project.demo
`http://localhost:8000`

## 概要

| コンポーネント       | バージョン  |
|-------------------|-----------|
| PHP               | 8.2.28       |
| Laravel           | 10.48.29      |
| MySQL             | 5.7       |
| Nginx             | 1.15.6    |
| Docker Compose     | 3.0       |

```
.
├── docker/
│   ├── app/
│   │   └── Dockerfile  # この後作成
│   └── web/
│       └── default.conf # この後作成
├── crud-app/           # 空のディレクトリとして作成
├── docker-compose.yml # この後作成
├── index.html         # この後作成 (Nginx初期確認用)
└── README.md          # (任意)
```

## 環境構築

### 1. docker-compose up -d --build
下記のディレクトリ構造を作成して、`docker/app/Dockerfile` `docker/web/default.conf` `docker-compose.yml`の中身を作成してから **docker-compose up -d --build** をする

```bash:bash
  % ll
total 24
drwxr-xr-x   7 metchakureha  staff   224B  5 16 22:45 ./
drwxr-xr-x   3 metchakureha  staff    96B  5 16 22:14 ../
drwxr-xr-x  12 metchakureha  staff   384B  5 16 22:28 .git/
drwxr-xr-x   4 metchakureha  staff   128B  5 16 22:39 docker/
-rw-r--r--   1 metchakureha  staff   880B  5 16 22:35 docker-compose.yml
-rw-r--r--   1 metchakureha  staff   227B  5 16 22:28 index.html
-rw-r--r--   1 metchakureha  staff     7B  5 16 22:15 README.md


  % ll -lR docker
total 0
drwxr-xr-x  3 metchakureha  staff  96  5 16 22:39 app
drwxr-xr-x  3 metchakureha  staff  96  5 16 22:39 web

docker/app:
total 8
-rw-r--r--  1 metchakureha  staff  518  5 16 22:48 Dockerfile

docker/web:
total 8
-rw-r--r--  1 metchakureha  staff  279  5 16 22:31 default.conf
```

### 2. Laravel:install
Laravelプロジェクトが /var/www/html（ホストマシンの crud-app ディレクトリにマウントされている場所）に作成され、.env.example が .env にコピーされ、アプリケーションキーも設定。
```
  % docker-compose exec app bash
root@de62d9c359f7:/var/www/html# cd /var/www/html
root@de62d9c359f7:/var/www/html# composer create-project --prefer-dist laravel/laravel . "10.*"
```

----

### 3. .envファイルを修正
```.env:.env
DB_CONNECTION=mysql
DB_HOST=mysql          # ← 変更: Docker Composeのサービス名 'mysql' を指定します
DB_PORT=3306
DB_DATABASE=laravel_db # ← 変更: docker-compose.yml で MYSQL_DATABASE に設定した値
DB_USERNAME=laravel_user # ← 変更: docker-compose.yml で MYSQL_USER に設定した値
DB_PASSWORD=password     # ← 変更: docker-compose.yml で MYSQL_PASSWORD に設定した値
```

### 4. NginxをLaravel向けに設定変更
```default.conf:
server {
    listen 80;
    server_name localhost;

    # ドキュメントルートをLaravelのpublicディレクトリに変更
    root /var/www/html/public;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # PHP-FPMへのリクエストを処理
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        # 'app' は docker-compose.yml で定義したPHP-FPMサービスのサービス名
        fastcgi_pass app:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    location ~ /\.ht {
        deny all;
    }
}
```


### 5. Nginx を再起動し Laravel が表示されるか確認
```
docker-compose down
docker-compose up -d --build
```
