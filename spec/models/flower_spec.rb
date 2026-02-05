# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '花機能', type: :request do
  let(:owner) { User.create!(name: 'Owner', email: "flower_owner_#{SecureRandom.hex(4)}@example.com", password: 'password') }
  let(:other_user) { User.create!(name: 'Other', email: "flower_other_#{SecureRandom.hex(4)}@example.com", password: 'password') }

  before do
    host! 'www.cocopos.net'
  end

  it '投稿に花をつけて取り消せる' do
    post_record = Post.create!(user: owner, body: 'public', post_type: :future, is_public: true)
    sign_in other_user

    post post_flower_path(post_record)
    expect(response).to have_http_status(:found)
    expect(post_record.reload.flowers_count).to eq(1)

    delete post_flower_path(post_record)
    expect(response).to have_http_status(:found)
    expect(post_record.reload.flowers_count).to eq(0)
  end

  it '非公開投稿には所有者以外が花をつけられない' do
    post_record = Post.create!(user: owner, body: 'private', post_type: :future, is_public: false)
    sign_in other_user

    post post_flower_path(post_record)

    expect(response).to redirect_to(posts_path)
    expect(post_record.reload.flowers_count).to eq(0)
  end

  it 'コメントにも花をつけられる' do
    post_record = Post.create!(user: owner, body: 'public', post_type: :future, is_public: true)
    comment = Comment.create!(user: owner, post: post_record, content: 'コメント')
    sign_in other_user

    post post_comment_flower_path(post_record, comment)

    expect(response).to have_http_status(:found)
    expect(comment.reload.flowers_count).to eq(1)
  end
end
