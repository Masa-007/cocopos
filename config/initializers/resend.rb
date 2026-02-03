# config/initializers/resend.rb
require "resend"

Resend.api_key = ENV.fetch("RESEND_API_KEY")

