# ベースステージ（共通部分）
FROM ruby:3.2.9 AS base
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

RUN apt-get update -qq \
  && apt-get install -y ca-certificates curl gnupg wget \
  && mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
  && NODE_MAJOR=20 \
  && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
  && curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /etc/apt/keyrings/yarn.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
  && apt-get update -qq \
  && apt-get install -y build-essential libpq-dev nodejs yarn vim \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /myapp
WORKDIR /myapp

RUN gem install bundler
COPY Gemfile Gemfile.lock /myapp/
RUN bundle install
COPY . /myapp

# 開発環境ステージ（ローカルメイン）
FROM base AS development
ENV RAILS_ENV=development
EXPOSE 3000
# ホットリロード対応、ローカル開発用
CMD ["bash", "-lc", "bin/rails server -b 0.0.0.0 -p 3000"]

# テスト環境ステージ（CI/CD用）
FROM base AS test
ENV RAILS_ENV=test
# テスト実行用
CMD ["bash", "-lc", "bundle exec rspec"]

# 本番環境ステージ（Render用・無料枠節約）
FROM base AS production
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true
RUN bundle exec rake assets:precompile
EXPOSE 10000
# Renderのポート設定に対応
CMD ["bash", "-lc", "bin/rails server -b 0.0.0.0 -p ${PORT:-10000}"]
