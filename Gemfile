# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.9'

# --- 基本 ---
gem 'bootsnap', require: false
gem 'concurrent-ruby', '~> 1.3'
gem 'pg', '~> 1.6'
gem 'puma', '~> 7.0'
gem 'rails', '~> 7.1.3'

gem 'devise'

gem 'kaminari'


# --- フロントエンド / アセット ---
gem 'foreman', '~> 0.90.0'
gem 'importmap-rails'     # JS管理
gem 'propshaft'           # Rails 7.1 デフォルトのアセット管理
gem 'stimulus-rails'      # Stimulus(JS)
gem 'turbo-rails'         # Turbo(Hotwire)

# --- Tailwind（CLI運用ならGem不要）---
# gem "tailwindcss-rails", "~> 2.0"

# --- 開発支援 ---
group :development do
  gem 'dotenv-rails'
  gem 'listen', '~> 3.8'
  gem 'web-console'

  # RuboCop
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end
