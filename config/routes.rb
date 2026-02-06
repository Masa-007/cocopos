# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  root 'static_pages#top'
  get 'privacy_policy', to: 'static_pages#privacy_policy'
  get 'terms', to: 'static_pages#terms', as: :terms

  # 投稿（public_uuid）配下に、コメントと花をまとめる
  resources :posts, param: :public_uuid do
    resources :comments, only: %i[create destroy edit update]

    # 投稿への花
    resource :flower, only: %i[create destroy], controller: :flowers

    # コメントへの花（コメントも UUID で扱うなら、ここも param を揃えるのが安全）
    resources :comments, param: :public_uuid, only: [] do
      resource :flower, only: %i[create destroy], controller: :flowers
    end
  end

  get 'mypage', to: 'users#mypage', as: :mypage
  get 'mypage/posts', to: 'users#mypage_posts', as: :mypage_posts

  post '/ai/generate_text', to: 'ai#generate_text'
end
