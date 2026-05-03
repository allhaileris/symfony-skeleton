# --- Этап 1: Сборщик (Builder) ---
FROM cgr.dev/chainguard/php:latest-dev AS builder

USER root

# Обновляем apk и устанавливаем ВСЕ необходимые расширения для PHP 8.5
RUN apk update && apk add --no-cache \
    php-8.5-ctype \
    php-8.5-dom \
    php-8.5-xml \
    php-8.5-simplexml \
    php-8.5-xmlreader \
    php-8.5-xmlwriter \
    php-8.5-sockets

ARG APP_ENV
RUN echo "Building version: ${APP_ENV}"

WORKDIR /app
COPY . .

# Теперь мы можем удалить --ignore-platform-req для установленных расширений
RUN APP_ENV=${APP_ENV} composer install --no-progress --prefer-dist \
    --ignore-platform-req=ext-amqp

RUN mkdir -p /app/var/cache/${APP_ENV}

# --- Этап 2: Финальный контейнер (Distroless runtime) ---
FROM cgr.dev/chainguard/php:latest

# Копируем RoadRunner
COPY --from=ghcr.io/roadrunner-server/roadrunner:latest /usr/bin/rr /usr/local/bin/rr

# 1. Копируем скомпилированные .so файлы расширений
COPY --from=builder /usr/lib/php/modules/ctype.so /usr/lib/php/modules/ctype.so
COPY --from=builder /usr/lib/php/modules/dom.so /usr/lib/php/modules/dom.so
COPY --from=builder /usr/lib/php/modules/xml.so /usr/lib/php/modules/xml.so
COPY --from=builder /usr/lib/php/modules/simplexml.so /usr/lib/php/modules/simplexml.so
COPY --from=builder /usr/lib/php/modules/xmlreader.so /usr/lib/php/modules/xmlreader.so
COPY --from=builder /usr/lib/php/modules/xmlwriter.so /usr/lib/php/modules/xmlwriter.so
COPY --from=builder /usr/lib/php/modules/sockets.so /usr/lib/php/modules/sockets.so

# 2. ВАЖНО: Копируем конфигурационные .ini файлы, чтобы PHP загрузил эти модули
COPY --from=builder /etc/php/conf.d/ /etc/php/conf.d/

# Копируем файлы приложения
COPY --from=builder --chown=nonroot:nonroot /app /app

EXPOSE 8000
ENTRYPOINT ["/usr/local/bin/rr"]
CMD ["serve", "-c", "/app/.rr.yaml"]
