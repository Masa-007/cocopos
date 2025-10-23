# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  # マイページ
  get 'mypage', to: 'users#mypage', as: :mypage
  get 'change_season', to: 'users#change_season', as: :change_season

  

  # トップページ
  root 'static_pages#top'
end