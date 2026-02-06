# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ユーザー登録', type: :request do
  before do
    host! 'www.cocopos.net'
  end

  let(:user) do
    User.create!(
      name: 'Existing User',
      email: "existing_user_#{SecureRandom.hex(4)}@example.com",
      password: 'password'
    )
  end

  it '有効な情報でサインアップできる' do
    expect do
      post user_registration_path, params: {
        user: {
          name: 'New User',
          email: "new_user_#{SecureRandom.hex(4)}@example.com",
          password: 'password',
          password_confirmation: 'password'
        }
      }
    end.to change(User, :count).by(1)

    expect(response).to have_http_status(:see_other)
  end

  it '名前がない場合はサインアップできない' do
    expect do
      post user_registration_path, params: {
        user: {
          name: '',
          email: "new_user_invalid_#{SecureRandom.hex(4)}@example.com",
          password: 'password',
          password_confirmation: 'password'
        }
      }
    end.not_to change(User, :count)

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'ログイン中のユーザーはユーザー名を編集できる' do
    sign_in user

    patch user_registration_path, params: {
      user: {
        name: 'Updated Name',
        email: user.email,
        current_password: 'password'
      }
    }

    expect(response).to have_http_status(:redirect)
    expect(user.reload.name).to eq('Updated Name')
  end

  it 'ログイン中のユーザーは自分のアカウントを削除できる' do
    sign_in user

    expect do
      delete user_registration_path
    end.to change(User, :count).by(-1)

    expect(response).to have_http_status(:redirect)
  end
end
