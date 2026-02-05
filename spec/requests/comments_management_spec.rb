# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'コメント管理', type: :request do
  let(:owner) { User.create!(name: 'Owner', email: "comment_owner_#{SecureRandom.hex(4)}@example.com", password: 'password') }
  let(:other_user) { User.create!(name: 'Other', email: "comment_other_#{SecureRandom.hex(4)}@example.com", password: 'password') }
  let(:admin_user) { User.create!(name: 'Admin', email: "comment_admin_#{SecureRandom.hex(4)}@example.com", password: 'password', admin: true) }

  before do
    host! 'www.cocopos.net'
  end

  it 'comment_allowedがfalseの投稿にはコメント作成できない' do
    post_record = Post.create!(user: owner, body: 'no comment', post_type: :future, is_public: true, comment_allowed: false)
    sign_in other_user

    post post_comments_path(post_record), params: { comment: { content: 'コメント' } }

    expect(response).to redirect_to(post_path(post_record))
    expect(post_record.comments.count).to eq(0)
  end

  it '非公開投稿は所有者以外コメント作成できない' do
    post_record = Post.create!(user: owner, body: 'private', post_type: :future, is_public: false, comment_allowed: true)
    sign_in other_user

    post post_comments_path(post_record), params: { comment: { content: 'コメント' } }

    expect(response).to redirect_to(posts_path)
    expect(post_record.comments.count).to eq(0)
  end

  it '管理者は他人コメントを削除できる' do
    post_record = Post.create!(user: owner, body: 'public', post_type: :future, is_public: true, comment_allowed: true)
    comment = Comment.create!(user: other_user, post: post_record, content: '削除対象')
    sign_in admin_user

    delete post_comment_path(post_record, comment)

    expect(response).to redirect_to(post_path(post_record))
    expect(Comment.exists?(comment.id)).to be(false)
  end

  it '管理者は他人コメントを編集できない' do
    post_record = Post.create!(user: owner, body: 'public', post_type: :future, is_public: true, comment_allowed: true)
    comment = Comment.create!(user: other_user, post: post_record, content: '編集対象')
    sign_in admin_user

    patch post_comment_path(post_record, comment), params: { comment: { content: '更新後' } }

    expect(response).to redirect_to(post_path(post_record))
    expect(comment.reload.content).to eq('編集対象')
  end
end
