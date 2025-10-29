# Rubyベースイメージ
FROM ruby:3.2.9 AS base
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

# Node / npm / PostgreSQLクライアントをセットアップ（Tailwind & JSビルド用）
RUN apt-get update -qq \
  && apt-get install -y ca-certificates curl build-essential libpq-dev postgresql-client vim \
  && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
  && apt-get install -y nodejs \
  && npm install -g npm@10 yarn \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /myapp

# bundler, foremanをグローバルインストール
RUN gem install bundler foreman

# 依存関係を先にコピーしてキャッシュを効かせる
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Entrypoint設定（サーバーPID削除してからRails起動）
RUN printf '#!/bin/bash\nset -e\nrm -f /myapp/tmp/pids/server.pid\nexec "$@"\n' > /usr/bin/entrypoint.sh \
  && chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]

# 開発環境ステージ
FROM base AS development
ENV RAILS_ENV=development
EXPOSE 3000
WORKDIR /myapp

# npm依存のインストール
COPY package*.json ./
RUN if [ -f package.json ]; then npm install; fi
COPY . .

# 開発専用 entrypoint
RUN printf '#!/bin/bash\n\
set -e\n\
echo "🧹 Cleaning old Rails state and assets..."\n\
rm -f tmp/pids/server.pid\n\
rm -rf public/assets/* app/assets/builds/*\n\
if [ -f "./app/assets/stylesheets/application.tailwind.css" ]; then\n\
  echo "🎨 Rebuilding Tailwind..."\n\
  npx tailwindcss -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/builds/application.css\n\
fi\n\
if [ -f "package.json" ]; then\n\
  echo "⚙️ Rebuilding JS (esbuild)..."\n\
  npm run build\n\
fi\n\
exec $@\n' > /usr/bin/dev-entrypoint.sh \
  && chmod +x /usr/bin/dev-entrypoint.sh

# 🧪 テスト環境ステージ
FROM base AS test
ENV RAILS_ENV=test
WORKDIR /myapp
COPY . .
CMD ["bash", "-lc", "bundle exec rspec"]

# 🚀 本番環境ステージ（Render 用）
FROM base AS production
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true
WORKDIR /myapp
EXPOSE 10000

ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY

COPY package*.json ./
RUN if [ -f package.json ]; then npm install; fi
COPY . .

# Tailwind & JSビルド → アセットプリコンパイル
RUN mkdir -p app/assets/builds tmp/pids \
  && npx tailwindcss -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/builds/application.css \
  && npm run build \
  && printf "production:\n  adapter: postgresql\n  encoding: unicode\n  pool: 5\n  url: <%%= ENV['DATABASE_URL'] %%>\n" > config/database.yml \
  && bundle exec rails assets:precompile

CMD mkdir -p tmp/pids && bundle exec rails db:migrate && \
    bundle exec puma -C config/puma.rb -b tcp://0.0.0.0:${PORT:-10000}

