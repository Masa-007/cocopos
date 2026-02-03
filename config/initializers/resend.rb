# config/initializers/resend.rb
if ENV['RESEND_API_KEY'].present?
  Resend.api_key = ENV['RESEND_API_KEY']
else
  Rails.logger.warn("[Resend] RESEND_API_KEY is missing (skip configuring Resend)")
end
