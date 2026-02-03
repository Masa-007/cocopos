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
  # Render の場合は通常 RAILS_SERVE_STATIC_FILES が設定されます（無ければ RENDER を見る）
  config.public_file_server.enabled =
    ENV['RAILS_SERVE_STATIC_FILES'].present? || ENV['RENDER'].present?

  # アセット
  config.assets.compile = false
  # config.assets.css_compressor = :sass

  # Active Storage
  config.active_storage.service = :local

  # HTTPS（Renderは自動SSL）
  config.force_ssl = true

  # メール（Deviseなどで必須）
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: 'cocopos.net', protocol: 'https' }
  config.action_mailer.delivery_method = :resend
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  # 実行時に Resend のキーが無いのは致命なので、production 起動時に検知して落とす
  if ENV['RESEND_API_KEY'].blank?
    raise 'RESEND_API_KEY is missing'
  end

  # ログ関連
  config.log_level = :info
  config.log_tags = [:request_id]
  config.active_support.report_deprecations = false
  config.log_formatter = ::Logger::Formatter.new

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # I18n
  config.i18n.fallbacks = true

  # データベース
  config.active_record.dump_schema_after_migration = false

  # セキュリティ（許可ホスト）
  config.hosts << 'cocopos.onrender.com'
  config.hosts << 'cocopos-staging.onrender.com'
  config.hosts << 'cocopos.net'
  config.hosts << 'www.cocopos.net'
end
