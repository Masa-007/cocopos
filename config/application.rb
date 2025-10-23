# frozen_string_literal: true

require_relative 'boot'
require 'rails/all' # Propshaftはこれに含まれています
require 'devise'

Bundler.require(*Rails.groups)

module Myapp
  class Application < Rails::Application
    config.load_defaults 7.1

    # Tailwind ビルド済みファイルを読み込むパスを追加
    config.assets.paths << Rails.root.join('app/assets/builds')

    # Propshaft では precompile 設定は不要（pathsにあるファイルを自動で解決）
    
    # 🌐 日本語をデフォルトロケールに設定
    config.i18n.default_locale = :ja

    # i18nファイルのロードパスを拡張（ymlファイルを自動読み込み）
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
  end
end
