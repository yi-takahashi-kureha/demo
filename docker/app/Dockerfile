FROM php:8.2-fpm

ARG UID
ARG GID

RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    libzip-dev libonig-dev libxml2-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath xml zip

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# --- [修正] GIDの衝突を解決するロジックを追加 ---
RUN EXISTING_GID_GROUP_NAME=$(getent group ${GID} | cut -d: -f1); \
    if [ -n "$EXISTING_GID_GROUP_NAME" ] && [ "$EXISTING_GID_GROUP_NAME" != "www-data" ]; then \
        groupdel "$EXISTING_GID_GROUP_NAME"; \
    fi; \
    groupmod -g ${GID} www-data; \
    usermod -u ${UID} www-data;

CMD ["php-fpm"]
