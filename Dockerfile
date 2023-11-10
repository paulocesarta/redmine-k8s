# Use Alpine Linux as base image
FROM alpine:latest

# Mantenha o Maintainer para informações de contato
MAINTAINER SeuNome <paulotavares3@gmail.com>

# Defina a versão do Redmine
ENV REDMINE_VERSION 5.1.0

# Instale as dependências necessárias
RUN apk --update --no-cache add \
    ruby \
    ruby-json \
    ruby-bigdecimal \
    ruby-webrick \
    tzdata \
    ca-certificates \
    postgresql-client \
    && apk --update --no-cache add --virtual build-dependencies \
    ruby-dev \
    build-base \
    libressl-dev \
    postgresql-dev \
    && gem install bundler \
    && update-ca-certificates \
    && mkdir /app

# Baixe e extraia o Redmine
RUN wget -O /app/redmine.tar.gz https://www.redmine.org/releases/redmine-$REDMINE_VERSION.tar.gz \
    && tar -xf /app/redmine.tar.gz -C /app \
    && mv /app/redmine-$REDMINE_VERSION /app/redmine \
    && rm /app/redmine.tar.gz \
    && cd /app/redmine \
    && bundle install --without development test

# Configure o banco de dados PostgreSQL externo
COPY database.yml /app/redmine/config/database.yml

# Exponha a porta 3000
EXPOSE 3000

# Defina o diretório de trabalho como /app/redmine
WORKDIR /app/redmine

# Comando para iniciar o Redmine
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
