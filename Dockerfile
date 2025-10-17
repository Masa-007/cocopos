# -----------------------------------------------------------
# ベースステージ（共通設定）
# -----------------------------------------------------------
FROM ruby:3.2.9 AS base
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

# Node.js / npm / yarn インストール（Tailwind ビルド用）
RUN apt-get update -qq \
  && apt-get install -y ca-certificates curl build-essential libpq-dev vim \
  && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
  && apt-get install -y nodejs \
  && npm install -g npm@10 yarn \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# アプリケーションセットアップ
WORKDIR /myapp
RUN gem install bundler foreman
COPY Gemfile Gemfile.lock /myapp/
RUN bundle install
COPY . /myapp

# -----------------------------------------------------------
# 開発環境ステージ
# -----------------------------------------------------------
FROM base AS development
ENV RAILS_ENV=development
EXPOSE 3000

# Foreman で Procfile.dev 内の Rails / Tailwind / JS を一括起動
CMD ["foreman", "start", "-f", "Procfile.dev"]

# -----------------------------------------------------------
# テスト環境ステージ
# -----------------------------------------------------------
FROM base AS test
ENV RAILS_ENV=test
CMD ["bash", "-lc", "bundle exec rspec"]

# -----------------------------------------------------------
# 本番環境ステージ
# -----------------------------------------------------------
FROM base AS production
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true

# Tailwind の CSS を事前ビルドしてからアセットプリコンパイル
RUN npx tailwindcss -i ./app/assets/stylesheets/application.tailwind.css \
  -o ./app/assets/builds/application.css && \
  bundle exec rails assets:precompile

EXPOSE 10000
CMD ["bash", "-lc", "bin/rails server -b 0.0.0.0 -p ${PORT:-10000}"]

