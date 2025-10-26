# frozen_string_literal: true

Rails.application.routes.draw do
  # Deviseユーザー認証
  devise_for :users

  # マイページ関連
  get 'mypage', to: 'users#mypage', as: :mypage
  get 'change_season', to: 'users#change_season', as: :change_season

  # 投稿関連
  resources :posts, only: [:index, :show, :new, :create]

  # トップページ
  root 'static_pages#top'

end
