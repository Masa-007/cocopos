# config/environments/development.rb
require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Rails 既定の設定
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true

  # Caching
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  # ActiveStorage
  config.active_storage.service = :local

  # メール設定
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false

  # デバッグ・ログ
  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true

  # Tailwind / Propshaft対応追加箇所 👇
  config.assets.paths << Rails.root.join("app/assets/builds")
  config.assets.compile = true
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=31536000'
  }

  # Optional: Action CableなどでCORSを無効化する場合
  # config.action_cable.disable_request_forgery_protection = true
end
