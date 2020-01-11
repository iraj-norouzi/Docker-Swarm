FROM m.docker-registry.ir/centos:7 as intermediate
LABEL stage=intermediate

WORKDIR /root/
RUN yum install -y \
        git && \
    git clone -b php7 https://github.com/serggp/php-protobuf

FROM php:7.3-cli


#Package   Version State
#event     2.3.0   stable
#imagick   3.4.3   stable
#pecl_http 3.1.0   stable
#pq        2.1.3   stable
#propro    2.1.0   stable
#raphf     2.0.0   stable

ENV TZ=GMT
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN \
    apt update && \
    pecl channel-update pecl.php.net && \
    echo "Start installation" && \
    echo "Install opcache mbstring" && \
    docker-php-ext-install -j$(nproc) opcache && \
    docker-php-ext-install -j$(nproc) mbstring && \
    docker-php-ext-enable opcache mbstring && \
    echo "Install pdo" && \
    apt-get install -y --no-install-recommends \
        libev-dev && \
    docker-php-ext-install -j$(nproc) pdo && \
    docker-php-ext-enable pdo && \
    echo "Install pdo_pgsql pgsql" && \
    apt install -y --no-install-recommends \
        libpq-dev && \
    docker-php-ext-install -j$(nproc) pdo_pgsql && \
    docker-php-ext-install -j$(nproc) pgsql && \
    docker-php-ext-enable pdo_pgsql pgsql && \
    echo "Install soap" && \
    apt install -y --no-install-recommends \
        libxml2-dev && \
    docker-php-ext-install -j$(nproc) soap && \
    docker-php-ext-enable soap && \
    echo "Install gd" && \
    apt install -y --no-install-recommends \
        libpng16-16 \
        libpng-dev \
        libjpeg-dev && \
    docker-php-ext-configure gd --with-jpeg-dir=/usr/lib && \
    docker-php-ext-install -j$(nproc) gd && \
    docker-php-ext-enable gd && \
    echo "Install imagick" && \
    apt install -y --no-install-recommends \
        libmagickwand-dev && \
    pecl install imagick && \
    docker-php-ext-enable imagick && \
    echo "Install pecl/raphf" && \
    printf "\n" | pecl install pecl/raphf && \
    docker-php-ext-enable raphf && \
    echo "Install event" && \
    apt install -y --no-install-recommends \
        libevent-dev \
        libssl-dev && \
    docker-php-ext-install -j$(nproc) sockets && \
    printf "\n" | pecl install event && \
    docker-php-ext-enable event && \
    echo "Install pq" && \
    printf "\n" | pecl install pq && \
    docker-php-ext-enable pq && \
    echo "Install propro" && \
    printf "\n" | pecl install propro && \
    docker-php-ext-enable propro && \
    echo "Install protobuf" && \
    printf "\n" | pecl install protobuf && \
    docker-php-ext-enable protobuf && \
    echo "Install pecl_http" && \
    apt install -y --no-install-recommends \
        libcurl4-openssl-dev && \
    printf "\n" | pecl install pecl_http && \
    docker-php-ext-enable http && \
    echo "Install pcntl" && \
    docker-php-ext-install -j$(nproc) pcntl && \
    docker-php-ext-enable pcntl && \
    echo "Install bcmath" && \
    docker-php-ext-install -j$(nproc) bcmath && \
    docker-php-ext-enable bcmath && \
    echo "Install ffmpeg" && \
    apt install -y ffmpeg && \
    echo "Install supervisor" && \
    apt install -y supervisor

COPY --from=intermediate /root/php-protobuf /root/php-protobuf
RUN cd /root/php-protobuf && \
    echo "install protobuf" && \
    phpize && \
    ./configure && \
    make -j$(nproc) && \
    make install

COPY . /home/iGap/
WORKDIR /home/iGap

RUN cp /home/iGap/worker.conf /etc/supervisor/conf.d/worker.conf

EXPOSE 7072
EXPOSE 8739
EXPOSE 7272
RUN /usr/bin/supervisord
CMD   /usr/bin/supervisord
RUN touch /home/iGap/app/temp/error.log

COPY ./run.sh /

RUN chmod +x /run.sh 
#&& bash /run.sh
ENTRYPOINT ["bash","/run.sh"]
