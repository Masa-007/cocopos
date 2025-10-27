# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  root 'static_pages#top'

  # 投稿関連（全アクション）
  resources :posts, only: %i[index show new create edit update destroy]

  # マイページ
  get 'mypage', to: 'users#mypage', as: :mypage
end
