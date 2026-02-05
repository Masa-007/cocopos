# frozen_string_literal: true

Rails.application.routes.draw do
  # Devise（ユーザー認証）
  devise_for :users, controllers: { registrations: 'users/registrations',
                                    omniauth_callbacks: 'users/omniauth_callbacks' }

  # ルートページ
  root 'static_pages#top'
  get 'privacy_policy', to: 'static_pages#privacy_policy'
  get 'terms', to: 'static_pages#terms', as: :terms
  # 投稿関連（ネスト構造）
  resources :posts, param: :public_uuid do
    # コメント（投稿に紐づく）
    resources :comments, only: %i[create destroy edit update]
  end

  # 花ボタンは投稿IDベースで扱う
  resources :posts, only: [] do
    resource :flower, only: %i[create destroy], controller: :flowers

    resources :comments, only: [] do
      resource :flower, only: %i[create destroy], controller: :flowers
    end
  end
  # マイページ
  get 'mypage', to: 'users#mypage', as: :mypage
  get 'mypage/posts', to: 'users#mypage_posts', as: :mypage_posts

  # AI文章生成（1日1回制限）
  post '/ai/generate_text', to: 'ai#generate_text'
end
