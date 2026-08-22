# QloApps (Hotel Management System) — PHP + Apache image
# Base: PHP 8.1 (within QloApps' supported >8.0 <8.5 range).
FROM php:8.1-apache

# --- System libraries needed to build the PHP extensions QloApps requires ---
RUN apt-get update && apt-get install -y --no-install-recommends \
        libpng-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        libzip-dev \
        libxml2-dev \
        libicu-dev \
        libmcrypt-dev \
        zip \
        unzip \
    && rm -rf /var/lib/apt/lists/*

# --- PHP extensions (composer.json: curl, dom, gd, mcrypt, openssl,
#     pdo_mysql, phar, simplexml, soap, zip — the rest ship with the base image) ---
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        gd \
        pdo_mysql \
        mysqli \
        soap \
        zip \
        intl \
        opcache \
        bcmath \
        exif \
    && pecl install mcrypt \
    && docker-php-ext-enable mcrypt

# --- Apache: friendly URLs (mod_rewrite) + allow QloApps' generated .htaccess ---
RUN a2enmod rewrite \
    && printf '<Directory /var/www/html/>\n    AllowOverride All\n    Require all granted\n</Directory>\n' \
        > /etc/apache2/conf-available/qloapps.conf \
    && a2enconf qloapps \
    && echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf \
    && a2enconf servername

# --- PHP runtime tuning recommended for PrestaShop/QloApps ---
RUN { \
        echo "memory_limit = 512M"; \
        echo "upload_max_filesize = 64M"; \
        echo "post_max_size = 64M"; \
        echo "max_execution_time = 300"; \
        echo "max_input_vars = 10000"; \
        echo "allow_url_fopen = On"; \
    } > /usr/local/etc/php/conf.d/qloapps.ini

# --- Application code ---
COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
