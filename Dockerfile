# PHP Docker image for Yii 2.0 Framework runtime
# ==============================================
ARG PHP_IMAGE_VERSION
FROM php:7.2-fpm
LABEL maintainer="raoptimus <resmus@gmail.com>"

# Install system packages for PHP extensions recommended for Yii 2.0 Framework
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
        apt-get -y install \
        gnupg2 && \
        apt-key update && \
        apt-get update && \
        apt-get -y install \
        g++ \
        git \
        curl \
        imagemagick \
        libfreetype6-dev \
        libcurl3-dev \
        libicu-dev \
        libfreetype6-dev \
        libjpeg-dev \
        libjpeg62-turbo-dev \
        libmagickwand-dev \
        libpq-dev \
        libpng-dev \
        libxml2-dev \
        zlib1g-dev \
        openssh-client \
        libgeoip-dev \
        nano \
        unzip \
        wget \
        zsh \
        cron \
        --no-install-recommends

# Install PHP extensions required for Yii 2.0 Framework
RUN docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ && \
        docker-php-ext-configure bcmath && \
        docker-php-ext-install \
        zip \
        curl \
        bcmath \
        exif \
        gd \
        iconv \
        intl \
        mbstring \
        opcache \
        pcntl \
        pdo_pgsql

# Install PECL extensions
# see http://stackoverflow.com/a/8154466/291573) for usage of `printf`
RUN printf "\n" | pecl install \
        imagick \
        igbinary \
        geoip-1.1.1 \
        redis \
        docker-php-ext-enable \
        imagick \
        geoip-1.1.1 \
        redis

# Check if Xdebug extension need to be compiled. Default is enabled
ARG PHP_ENABLE_XDEBUG
RUN if [ 0 -ne "${PHP_ENABLE_XDEBUG:-0}" ] ; then cd /tmp && \
        git clone git://github.com/xdebug/xdebug.git && \
        cd xdebug && \
        git checkout 52adff7539109db592d07d3f6c325f6ee2a7669f && \
        phpize && \
        ./configure --enable-xdebug && \
        make && \
        make install && \
        rm -rf /tmp/xdebug \
        ; fi

# Environment settings
ENV PHP_USER_ID=33 \
        PHP_ENABLE_XDEBUG=0 \
        PATH=/var/www:/var/www/vendor/bin:/root/.composer/vendor/bin:$PATH \
        TERM=linux \
        VERSION_PRESTISSIMO_PLUGIN=^0.3.7 \
        VERSION_COMPOSER_ASSET_PLUGIN=^1.4.3 \
        COMPOSER_ALLOW_SUPERUSER=1 \
        EDITOR='nano'

# Install oh-my-zsh
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh && \ 
        chsh -s /bin/zsh

# Add configuration files
COPY image-files/ /

# Add GITHUB_API_TOKEN support for composer
RUN chmod 700 \
        /usr/local/bin/docker-entrypoint.sh \
        /usr/local/bin/composer

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- \
        --filename=composer.phar \
        --install-dir=/usr/local/bin && \
        composer clear-cache

# Install composer plugins
RUN composer global require --optimize-autoloader \
        "fxp/composer-asset-plugin:${VERSION_COMPOSER_ASSET_PLUGIN}" \
        "hirak/prestissimo:${VERSION_PRESTISSIMO_PLUGIN}" && \
        composer global dumpautoload --optimize && \
        composer clear-cache

# Clean
RUN apt-get clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Working directory for PHP
WORKDIR /var/www

# Startup script for FPM
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["php-fpm"]
