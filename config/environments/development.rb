# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # コードを都度リロード
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true

  # キャッシュ設定
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  # Active Storage
  config.active_storage.service = :local

  # メール（Devise用）
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.action_mailer.delivery_method = :resend
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.default_url_options = {
    host: 'localhost',
    port: 3000,
    protocol: 'http'
  }

  # ログ・デバッグ
  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true

  # アセット関連
  config.assets.paths += [
    Rails.root.join('app/assets/builds'),
    Rails.public_path.join('assets')
  ]

  # 開発時：ビルド済みCSSを即反映
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=0'
  }

  config.assets.debug = true
  config.assets.compile = true
end
