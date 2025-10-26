# frozen_string_literal: true

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

# controllers ディレクトリ
pin_all_from "app/javascript/controllers", under: "controllers"

# posts ディレクトリ（まとめて pin）
pin_all_from "app/javascript/posts", under: "posts"

# 単体スクリプト
pin "modal", to: "modal.js"
