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

  let(:google_user) do
    User.create!(
      name: 'Google User',
      email: "google_user_#{SecureRandom.hex(4)}@example.com",
      password: 'password',
      provider: 'google_oauth2',
      uid: SecureRandom.uuid
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

  it 'デモアカウントは削除できない' do
    demo_user = User.create!(
      name: 'Demo User',
      email: 'cocopos.demo@example.com',
      password: 'password'
    )

    sign_in demo_user
    allow(User).to receive(:demo_account_emails).and_return(['cocopos.demo@example.com'])

    expect do
      delete user_registration_path
    end.not_to change(User, :count)

    expect(response).to redirect_to(edit_user_registration_path)
    follow_redirect!
    expect(response.body).to include('デモアカウントは削除出来ません。')
  end

  it 'デモアカウントはユーザー名を変更できない' do
    demo_user = User.create!(
      name: 'お試しさん',
      email: 'cocopos.demo@example.com',
      password: 'password'
    )

    sign_in demo_user
    allow(User).to receive(:demo_account_emails).and_return(['cocopos.demo@example.com'])

    patch user_registration_path, params: {
      user: {
        name: 'Changed Name',
        email: demo_user.email,
        current_password: 'password'
      }
    }

    expect(response).to redirect_to(edit_user_registration_path)
    follow_redirect!
    expect(response.body).to include('デモアカウントのユーザー名は変更できません。')
    expect(demo_user.reload.name).to eq('お試しさん')
  end

  it 'ログイン中のユーザーは自分のアカウントを削除できる' do
    sign_in user

    expect do
      delete user_registration_path
    end.to change(User, :count).by(-1)

    expect(response).to have_http_status(:redirect)
  end
end
