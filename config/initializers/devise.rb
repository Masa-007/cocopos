# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Devise.setup do |config|
  # 🔑 本番での暗号化キー（必須）
  config.secret_key = ENV['DEVISE_SECRET_KEY'] if Rails.env.production?

  # 📮 メール送信設定（最低限）
  config.mailer_sender = ENV.fetch('MAILER_SENDER', 'ENV.fetch("MAIL-FROM")')
  config.paranoid = true

  # ORM設定（標準）
  require 'devise/orm/active_record'

  # 認証キー設定
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  # セッション設定
  config.skip_session_storage = [:http_auth]

  # bcryptコスト
  config.stretches = Rails.env.test? ? 1 : 12

  # メール変更確認
  config.reconfirmable = true

  # パスワード長
  config.password_length = 6..128

  # Emailバリデーション
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # パスワードリセット有効期間
  config.reset_password_within = 6.hours

  # Remember me クッキー設定（HTTPS対応）
  config.rememberable_options = { secure: true } if Rails.env.production?

  if ENV['GOOGLE_CLIENT_ID'].present? && ENV['GOOGLE_CLIENT_SECRET'].present?
    config.omniauth :google_oauth2,
                    ENV['GOOGLE_CLIENT_ID'],
                    ENV['GOOGLE_CLIENT_SECRET'],
                    prompt: 'select_account',
                    image_aspect_ratio: 'square',
                    image_size: 50
  end
  # サインアウトメソッド
  config.sign_out_via = :delete

  # Hotwire/Turbo 用のレスポンダ設定
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other
end
