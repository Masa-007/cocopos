require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

module Myapp
  class Application < Rails::Application
    config.load_defaults 7.0

    # builds フォルダをアセットパスに追加
    config.assets.paths << Rails.root.join("app/assets/builds")

    # application.css をプリコンパイル対象に追加（パスは省略）
    config.assets.precompile += ["application.css"]

    # 他の設定はそのまま
  end
end
