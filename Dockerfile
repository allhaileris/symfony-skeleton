# build
FROM php:8.2-fpm-alpine AS builder
ARG APP_ENV=${APP_ENV}

RUN apk add --no-cache --update php82 git
WORKDIR /opt/app
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
COPY . .
RUN if [ "$APP_ENV" = "dev" ]; \
    then \
        composer install --ignore-platform-reqs && mv .rr.dev.yaml .rr.yaml; \
    else \
        composer install --ignore-platform-reqs --no-dev --optimize-autoloader && rm .rr.dev.yaml; \
    fi

# final
FROM alpine
ARG APP_ENV=${APP_ENV}
RUN apk add --no-cache --update \
    php82 \
    php82-curl \
    php82-session \
    php82-dom \
    php82-simplexml \
    php82-gd \
    php82-intl \
    php82-ctype \
    php82-zip \
    php82-tokenizer \
    php82-iconv \
    php82-pdo_pgsql && \
    ln -s /usr/bin/php82 /usr/bin/php

WORKDIR /opt/app
COPY --from=builder /opt/app/ .
COPY --from=builder /opt/app/bin/rr /usr/local/bin/rr

EXPOSE 8000

ENTRYPOINT ["/usr/local/bin/rr"]

# Provide default arguments to RoadRunner (optional, can be overridden by docker run)
CMD ["serve", "-c", "/opt/app/.rr.yaml", "--debug"]
