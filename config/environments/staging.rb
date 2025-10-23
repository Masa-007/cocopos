# frozen_string_literal: true
require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # --- 基本設定 ---
  config.cache_classes = true
  config.eager_load = true

  # --- エラーレポート ---
  config.consider_all_requests_local = true  # ステージングではtrueでOK（エラー内容が見える）

  # --- 静的ファイルの配信 ---
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present? || true

  # --- アセット ---
  config.assets.compile = false

  # --- Active Storage ---
  config.active_storage.service = :local

  # --- ログ ---
  config.log_level = :info
  config.i18n.fallbacks = true

  # --- ホスト許可 ---
  config.hosts << "cocopos-staging.onrender.com"

  # --- DB接続（DATABASE_URLを使用）---
  # database.yml 側で ENV["DATABASE_URL"] を参照しているためここは不要
end
