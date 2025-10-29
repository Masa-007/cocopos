# frozen_string_literal: true

Rails.application.routes.draw do
  # Devise（ユーザー認証）
  devise_for :users

  # ルートページ
  root 'static_pages#top'

  # 投稿関連（ネスト構造）
  resources :posts do
    # コメント（投稿に紐づく）
    resources :comments, only: %i[create destroy edit update] do
      # コメントにも花ボタンを設置（ポリモーフィック対応）
      resource :flower, only: %i[create destroy]
    end

    # 投稿にも花ボタンを設置
    resource :flower, only: %i[create destroy]
  end

  # マイページ
  get 'mypage', to: 'users#mypage', as: :mypage
end
