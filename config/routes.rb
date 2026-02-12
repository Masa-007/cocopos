# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  devise_scope :user do
    get 'users/auth/google_oauth2/reauth', to: 'users/registrations#google_reauth', as: :google_reauth_user
  end

  root 'static_pages#top'
  get 'privacy_policy', to: 'static_pages#privacy_policy'
  get 'terms', to: 'static_pages#terms', as: :terms

  resources :posts, param: :public_uuid do
    resources :comments, only: %i[create destroy edit update]
    resource :flower, only: %i[create destroy], controller: :flowers
    resources :comments, param: :public_uuid, only: [] do
      resource :flower, only: %i[create destroy], controller: :flowers
    end
  end

  get 'mypage', to: 'users#mypage', as: :mypage
  get 'mypage/posts', to: 'users#mypage_posts', as: :mypage_posts
  get 'mypage/records', to: 'users#mypage_records', as: :mypage_records

  post '/ai/generate_text', to: 'ai#generate_text'
end
