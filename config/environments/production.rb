# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # --- 基本設定 ---
  config.cache_classes = true
  config.eager_load = true

  # --- エラーレポート・キャッシュ ---
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # --- master.key（必須） ---
  # 本番でcredentialsを復号するため、必ずtrueに。
  config.require_master_key = true

  # --- 静的ファイルの配信 ---
  # RenderなどではENVが無いこともあるのでtrueをフォールバック。
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present? || true

  # --- アセット ---
  # プリコンパイルしたものを配信する
  config.assets.compile = false
  # config.assets.css_compressor = :sass

  # --- ファイル配信 ---
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # --- Active Storage ---
  config.active_storage.service = :local

  # --- HTTPS（Renderは自動的にSSL） ---
  config.force_ssl = true

  # --- ログ関連 ---
  config.log_level = :info
  config.log_tags = [:request_id]

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # --- I18n ---
  config.i18n.fallbacks = true

  # --- メール ---
  config.action_mailer.perform_caching = false
  # config.action_mailer.raise_delivery_errors = false

  # --- データベース ---
  config.active_record.dump_schema_after_migration = false

  # --- Deprecation ---
  config.active_support.report_deprecations = false
  config.log_formatter = ::Logger::Formatter.new

  # --- セキュリティ（Renderのドメインを許可） ---
  config.hosts << "cocopos.onrender.com"

  # --- コメント: 他環境で再利用する際はここを書き換え ---
  # 例: config.hosts << "www.example.com"
end

