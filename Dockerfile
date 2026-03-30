FROM cgr.dev/chainguard/php:latest-dev AS builder
USER root
# Uncaught Error: Call to undefined function Symfony\Component\Config\ctype_alpha()
RUN apk update && apk add php-ctype
ARG APP_ENV
RUN echo "Building version: ${APP_ENV}"
WORKDIR /app
COPY . .
RUN APP_ENV=${APP_ENV} composer install --no-progress --prefer-dist \
    --ignore-platform-req=ext-amqp \
    --ignore-platform-req=ext-dom \
    --ignore-platform-req=ext-sockets \
    --ignore-platform-req=ext-xml \
    --ignore-platform-req=ext-xmlwriter
RUN mkdir -p /app/var/cache/${APP_ENV}

FROM cgr.dev/chainguard/php:latest
COPY --from=builder /usr/lib/php/modules/ctype.so /usr/lib/php/modules/ctype.so
COPY --from=ghcr.io/roadrunner-server/roadrunner:latest /usr/bin/rr /usr/local/bin/rr
COPY --from=builder --chown=nonroot:nonroot /app /app
EXPOSE 8000
ENTRYPOINT ["/usr/local/bin/rr"]
CMD ["serve", "-c", "/app/.rr.yaml"]
