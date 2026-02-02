# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # 基本設定
  config.cache_classes = true
  config.eager_load = true

  # エラーレポート・キャッシュ
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # master.key（必須）
  config.require_master_key = true

  # 静的ファイル配信
  # Renderなどの環境変数を優先、無ければtrueをフォールバック
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present? || ENV['RENDER'].present? || true

  # アセット
  config.assets.compile = false
  # config.assets.css_compressor = :sass

  # Active Storage
  config.active_storage.service = :local

  # HTTPS（Renderは自動SSL）
  config.force_ssl = true

  # メール（Deviseなどで必須）
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: 'https://cocopos.onrender.com' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: ENV.fetch('SMTP_ADDRESS', 'smtp.sendgrid.net'),
    port: ENV.fetch('SMTP_PORT', 587),
    domain: ENV.fetch('SMTP_DOMAIN', 'cocopos.onrender.com'),
    user_name: ENV.fetch('SMTP_USERNAME', nil),
    password: ENV.fetch('SMTP_PASSWORD', nil),
    authentication: ENV.fetch('SMTP_AUTHENTICATION', 'plain'),
    enable_starttls_auto: ENV.fetch('SMTP_ENABLE_STARTTLS_AUTO', 'true') == 'true'
  }

  # ログ関連
  config.log_level = :info
  config.log_tags = [:request_id]
  config.active_support.report_deprecations = false
  config.log_formatter = ::Logger::Formatter.new

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # I18n
  config.i18n.fallbacks = true

  # データベース
  config.active_record.dump_schema_after_migration = false

  # セキュリティ（Renderのドメインを許可）
  config.hosts << 'cocopos.onrender.com'
  config.hosts << 'cocopos-staging.onrender.com'
end
