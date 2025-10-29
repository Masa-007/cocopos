# frozen_string_literal: true

Rails.application.routes.draw do
  # Devise（ユーザー認証）
  devise_for :users

  # ルート
  root 'static_pages#top'

  # 投稿関連（全アクション）
  resources :posts do
    resources :comments, only: %i[create destroy edit update]
    resource :flower, only: %i[create destroy]
  end

  # マイページ
  get 'mypage', to: 'users#mypage', as: :mypage
end
