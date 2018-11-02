# PHP Docker image for Yii 2.0 Framework runtime
# ==============================================
ARG PHP_IMAGE_VERSION
FROM yii2-php:latest
LABEL maintainer="raoptimus <resmus@gmail.com>"

RUN cd /tmp && \
        git clone git://github.com/xdebug/xdebug.git && \
        cd xdebug && \
        git checkout 52adff7539109db592d07d3f6c325f6ee2a7669f && \
        phpize && \
        ./configure --enable-xdebug && \
        make && \
        make install && \
        rm -rf /tmp/xdebug \