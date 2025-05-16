# Project.demo

### docker-compose up -d --build

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

### Laravel:install
Laravelプロジェクトが /var/www/html（ホストマシンの crud-app ディレクトリにマウントされている場所）に作成され、.env.example が .env にコピーされ、アプリケーションキーも設定。
```
  % docker-compose exec app bash
root@de62d9c359f7:/var/www/html# cd /var/www/html
root@de62d9c359f7:/var/www/html# composer create-project --prefer-dist laravel/laravel . "10.*"
```
