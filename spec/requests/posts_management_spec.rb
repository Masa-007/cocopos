# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '投稿管理', type: :request do
  let(:user) { User.create!(name: 'Owner', email: "owner_#{SecureRandom.hex(4)}@example.com", password: 'password') }
  let(:other_user) do
    User.create!(name: 'Other', email: "other_#{SecureRandom.hex(4)}@example.com", password: 'password')
  end

  before do
    host! 'www.cocopos.net'
  end

  it '非公開投稿の詳細は他ユーザーに閲覧させない' do
    post_record = Post.create!(user:, body: 'private post body', post_type: :future, is_public: false)
    sign_in other_user

    get post_path(post_record)

    expect(response).to redirect_to(posts_path)
  end

  it '公開設定がfalseの投稿作成時はcomment_allowedがfalseになる' do
    sign_in user

    post posts_path, params: {
      post: {
        body: 'private future',
        post_type: 'future',
        is_public: '0',
        comment_allowed: '1'
      }
    }

    created = Post.order(:created_at).last
    expect(created.is_public).to be(false)
    expect(created.comment_allowed).to be(false)
  end

  it 'JSON形式の投稿作成成功時は200でid等を返す' do
    sign_in user

    post posts_path(format: :json), params: {
      post: {
        body: 'json future',
        post_type: 'future',
        is_public: '1',
        comment_allowed: '1'
      }
    }

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['success']).to be(true)
    expect(response.parsed_body['data']['post_type']).to eq('future')
  end

  it 'JSON形式の投稿作成失敗時は422を返す' do
    sign_in user

    post posts_path(format: :json), params: {
      post: {
        body: '',
        post_type: 'future',
        is_public: '1',
        comment_allowed: '1'
      }
    }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body['success']).to be(false)
    expect(response.parsed_body['errors']).to be_present
  end

  it '編集権限のないユーザーはupdateできない' do
    post_record = Post.create!(user:, body: 'edit target', post_type: :future, is_public: true)
    sign_in other_user

    patch post_path(post_record), params: {
      post: {
        body: 'updated body'
      }
    }

    expect(response).to redirect_to(posts_path)
    expect(post_record.reload.body).to eq('edit target')
  end
end
