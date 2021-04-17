FROM ubuntu:18.04 as base

ARG PHP_VERSION=7.4
ARG BUILD_ENV=dev
ARG PROJECT_NAME=cgcorp
ENV DEBIAN_FRONTEND noninteractive

# PHP | ZIP | VIM | CURL | SUPERVISOR #
RUN apt-get update && \
    apt-get install software-properties-common -y && \
    add-apt-repository ppa:ondrej/php -y && \
    apt-get install \
    php${PHP_VERSION} \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-dev \
    zip \
    vim \
    unzip \
    curl \
    libcurl3-openssl-dev \
    supervisor \
    ghostscript \
    build-essential \
    -y

RUN if [ "$BUILD_ENV" = "dev" ]; then curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; fi

COPY .docker/config/php/php.ini /etc/php/${PHP_VERSION}/cli/php.ini
COPY .docker/config/php/php-fpm.ini /etc/php/${PHP_VERSION}/fpm/php.ini

# NGINX #
RUN apt-get install nginx -y
COPY .docker/config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY .docker/config/nginx/ssl /etc/nginx/ssl
COPY .docker/config/nginx/sites/${BUILD_ENV}-* /etc/nginx/sites-enabled/

# Supervisor
RUN mkdir /var/run/php/ && chmod 755 /run/php/
COPY .docker/config/supervisor/supervisor.conf /etc/supervisord.conf

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

# Set default work directory
WORKDIR /var/www/${PROJECT_NAME}

ARG BUILD_ENV=dev
FROM composer AS dependencies
COPY app/composer.json /app
COPY app/composer.lock /app
COPY app/symfony.lock /app
RUN composer install --optimize-autoloader --ignore-platform-reqs --no-scripts

LABEL image=dependencies


FROM base
ARG PROJECT_NAME=cgcorp
ARG BUILD_ENV=dev

COPY app /var/www/${PROJECT_NAME}

# Copy Vendor in
COPY --chown=www-data:www-data --from=dependencies app/vendor /var/www/${PROJECT_NAME}/vendor

COPY .docker/docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh
WORKDIR /var/www/${PROJECT_NAME}
CMD ["/docker-entrypoint.sh"]

EXPOSE 80
