FROM php:7.4-fpm as builder

WORKDIR /var/www

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo pdo_mysql \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \ 
    && apt-get clean \
    && rm -rf /var/www/html \
    && pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

ADD https://getcomposer.org/composer-stable.phar /usr/bin/composer

RUN chmod 755 /usr/bin/composer \
    && rm -rf html/

COPY . /var/www 

RUN  chown -R www-data:www-data storage/ \
  && chmod -R 2775 storage/ \
  && ln -s public html \
  && php artisan key:generate \
  && cp .env-production .env 



FROM builder 
WORKDIR /var/www

EXPOSE 9000
ENTRYPOINT ["php-fpm"] 
