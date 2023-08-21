FROM composer:2.4.3 as build
WORKDIR /app
COPY . /app

RUN composer install

FROM node:18.16.0 as  nodejs
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

FROM php:8.2.8-apache
EXPOSE 80
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd   pdo opcache
RUN a2enmod rewrite
COPY --from=build /app/public /var/www/html
COPY --from=build /app /var/www/
COPY --from=nodejs /app/public/build /var/www/html/build
COPY --from=nodejs /app/public/build/manifest.json /var/www/public/build/manifest.json
RUN chown -R www-data:www-data /var/www
#COPY vhost.conf /etc/apache2/sites-available/000-default.conf