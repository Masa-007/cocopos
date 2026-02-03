# frozen_string_literal: true
require_relative "production"

Rails.application.configure do
  config.consider_all_requests_local = true

  config.action_mailer.default_url_options = {
    host: "cocopos-staging.onrender.com",
    protocol: "https"
  }

  config.action_mailer.delivery_method = :resend
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  # ホスト許可（
  config.hosts << "cocopos-staging.onrender.com"

end
