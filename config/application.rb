# frozen_string_literal: true

require_relative 'boot'
require 'rails/all'

Bundler.require(*Rails.groups)

module Myapp
  class Application < Rails::Application
    config.load_defaults 7.1

    # 日本語をデフォルトロケールに設定
    config.i18n.default_locale = :ja
    config.i18n.load_path += Rails.root.glob('config/locales/**/*.{rb,yml}')

    # タイムゾーンを日本時間に設定
    config.time_zone = 'Asia/Tokyo'
    config.active_record.default_timezone = :local
  end
end
