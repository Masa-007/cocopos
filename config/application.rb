require_relative "boot"
require "rails/all" # Propshaftはこれに含まれています

Bundler.require(*Rails.groups)

module Myapp
  class Application < Rails::Application
    config.load_defaults 7.1

    # Tailwindビルド済みファイルを読み込むパスを追加
    config.assets.paths << Rails.root.join("app/assets/builds")

    # Propshaft では precompile 設定は不要
    # アセットは paths にあるファイルを自動的に解決します
  end
end
