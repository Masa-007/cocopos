# -----------------------------------------------------------
# ベースステージ（共通設定）
# -----------------------------------------------------------
FROM ruby:3.2.9 AS base
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

# Node.js / npm / yarn / PostgreSQLクライアント インストール（Tailwind ビルド用）
RUN apt-get update -qq \
  && apt-get install -y ca-certificates curl build-essential libpq-dev postgresql-client vim \
  && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
  && apt-get install -y nodejs \
  && npm install -g npm@10 yarn \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------
# アプリケーションセットアップ
# -----------------------------------------------------------
WORKDIR /myapp
RUN gem install bundler foreman
COPY Gemfile Gemfile.lock /myapp/
RUN bundle install
COPY . /myapp

# -----------------------------------------------------------
# Entrypoint設定（Railsサーバー起動前にPIDファイル削除）
# -----------------------------------------------------------
RUN echo '#!/bin/bash\n\
set -e\n\
rm -f /myapp/tmp/pids/server.pid\n\
exec "$@"' > /usr/bin/entrypoint.sh \
  && chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]

# -----------------------------------------------------------
# 開発環境ステージ
# -----------------------------------------------------------
FROM base AS development
ENV RAILS_ENV=development
EXPOSE 3000
WORKDIR /myapp

# npm install（package.json が存在すれば実行）
COPY package*.json ./
RUN if [ -f package.json ]; then npm install; fi
COPY . .

# ✅ 開発専用 entrypoint（起動時にアセットを毎回リセット）
RUN echo '#!/bin/bash\n\
set -e\n\
echo "🧹 Cleaning old Rails state and assets..."\n\
rm -f tmp/pids/server.pid\n\
rm -rf public/assets/* app/assets/builds/*\n\
if [ -f "./app/assets/stylesheets/application.tailwind.css" ]; then\n\
  echo "🎨 Rebuilding Tailwind..."\n\
  npx tailwindcss -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/builds/application.css\n\
fi\n\
echo "📦 Precompiling Rails assets..."\n\
bundle exec rails assets:precompile || echo "⚠️ skipped (dev mode)"\n\
exec \"$@\"' > /usr/bin/dev-entrypoint.sh \
  && chmod +x /usr/bin/dev-entrypoint.sh

ENTRYPOINT ["/usr/bin/dev-entrypoint.sh"]
CMD ["foreman", "start", "-f", "Procfile.dev"]

# -----------------------------------------------------------
# テスト環境ステージ
# -----------------------------------------------------------
FROM base AS test
ENV RAILS_ENV=test
CMD ["bash", "-lc", "bundle exec rspec"]

# -----------------------------------------------------------
# 本番環境ステージ（Render 用）
# -----------------------------------------------------------
FROM base AS production
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true
WORKDIR /myapp
EXPOSE 10000

ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY

# ✅ Tailwind & JS ビルド → ダミーDB設定 → アセットプリコンパイル
RUN npm install \
  && mkdir -p app/assets/builds tmp/pids \
  && npx tailwindcss -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/builds/application.css \
  && npm run build \
  && echo "production:\n  adapter: postgresql\n  encoding: unicode\n  pool: 5\n  url: <%= ENV['DATABASE_URL'] %>" > config/database.yml \
  && bundle exec rails assets:precompile

# ✅ 起動時に tmp/pids を保証してから Rails 起動
CMD mkdir -p tmp/pids && bundle exec rails db:migrate && bundle exec puma -C config/puma.rb -b tcp://0.0.0.0:${PORT:-10000}
