# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '投稿管理', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:owner) do
    User.create!(
      name: 'Owner',
      email: "owner_#{SecureRandom.hex(4)}@example.com",
      password: 'password'
    )
  end

  let(:other_user) do
    User.create!(
      name: 'Other',
      email: "other_#{SecureRandom.hex(4)}@example.com",
      password: 'password'
    )
  end

  before do
    host! 'www.cocopos.net'
  end

  it '新規投稿画面にコメント設定が表示される' do
    sign_in owner

    get new_post_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('💬 コメント設定')
    expect(response.body).to include('コメントを許可する')
    expect(response.body).to include('コメント不要')
    expect(response.body).to include('post-submit post-type-fields post-visibility')
  end

  it 'デモアカウントの新規投稿画面ではAI利用案内が1日3回表示になる' do
    demo_user = User.create!(
      name: 'お試しさん',
      email: 'cocopos.demo@example.com',
      password: 'password'
    )
    sign_in demo_user

    get new_post_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('本日の残り 3 / 3')
    expect(response.body).to include('※デモアカウントに限り1日3回までAI機能が使用可能です')
  end

  it '通常アカウントの新規投稿画面ではAI利用案内が従来どおり表示される' do
    sign_in owner

    get new_post_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('本日の残り 1 / 1')
    expect(response.body).to include('※ AI本文補助は1日1回まで利用できます')
  end

  it '公開投稿でcomment_allowedがtrueならコメント作成できる' do
    post_record = Post.create!(
      user: owner,
      body: 'commentable',
      post_type: :future,
      is_public: true,
      comment_allowed: true,
      deadline: Date.current
    )
    sign_in other_user

    expect do
      post post_comments_path(post_record), params: { comment: { content: 'コメント成功' } }
    end.to change(post_record.comments, :count).by(1)

    expect(response).to redirect_to(post_path(post_record))
  end

  it '非公開投稿の詳細は他ユーザーに閲覧させない' do
    post_record = Post.create!(
      user: owner,
      body: 'private post body',
      post_type: :future,
      is_public: false,
      deadline: Date.current
    )
    sign_in other_user

    get post_path(post_record)

    expect(response).to redirect_to(posts_path)
  end

  it '公開設定がfalseの投稿作成時はcomment_allowedがfalseになる' do
    sign_in owner

    post posts_path, params: {
      post: {
        body: 'private future',
        post_type: 'future',
        is_public: '0',
        comment_allowed: '1',
        deadline: Date.current.to_s
      }
    }

    created = Post.order(:created_at).last
    expect(created.is_public).to be(false)
    expect(created.comment_allowed).to be(false)
  end

  it 'JSON形式の投稿作成成功時は200でid等を返す' do
    sign_in owner

    post posts_path(format: :json), params: {
      post: {
        body: 'json future',
        post_type: 'future',
        is_public: '1',
        comment_allowed: '1',
        deadline: Date.current.to_s
      }
    }

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['success']).to be(true)
    expect(response.parsed_body['data']['post_type']).to eq('future')
  end

  it 'JSON形式の投稿作成失敗時は422を返す' do
    sign_in owner

    post posts_path(format: :json), params: {
      post: {
        body: '',
        post_type: 'future',
        is_public: '1',
        deadline: Date.current.to_s
      }
    }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body['success']).to be(false)
    expect(response.parsed_body['errors']).to be_present
  end

  it 'HTML形式の投稿作成失敗時は不足項目のエラーメッセージを表示する' do
    sign_in owner

    post posts_path, params: {
      post: {
        body: '',
        post_type: 'future',
        is_public: '1',
        comment_allowed: '1',
        deadline: Date.current.to_s
      }
    }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include('入力内容を確認してください')
    expect(response.body).to include('本文')
  end

  it 'organize投稿で気分未選択だと理由を表示する' do
    sign_in owner

    post posts_path, params: {
      post: {
        body: 'organize body',
        post_type: 'organize',
        is_public: '1',
        comment_allowed: '1',
        deadline: Date.current.to_s
      }
    }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include('気分を選択してください')
  end

  it 'thanks投稿で感謝対象未選択だと理由を表示する' do
    sign_in owner

    post posts_path, params: {
      post: {
        body: 'thanks body',
        post_type: 'thanks',
        is_public: '1',
        comment_allowed: '1',
        deadline: Date.current.to_s
      }
    }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include('感謝対象を選択してください')
  end

  it 'future投稿が達成済みなら期限超過でも達成済み表示を優先する' do
    post_record = Post.create!(
      user: owner,
      body: 'done future',
      post_type: :future,
      is_public: true,
      progress: 100,
      deadline: 3.days.from_now.to_date
    )
    sign_in owner

    travel_to 5.days.from_now do
      get post_path(post_record)

      expect(response.body).to include('🎉 <strong>達成済み</strong>')
      expect(response.body).not_to include('期限から <strong>3日</strong> 経過しています')
    end
  end

  it 'future投稿で期限日未入力だと理由を表示する' do
    sign_in owner

    post posts_path, params: {
      post: {
        body: 'future body',
        post_type: 'future',
        is_public: '1',
        comment_allowed: '1',
        deadline: ''
      }
    }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include('期限日を入力してください')
  end

  it '編集権限のないユーザーはupdateできない' do
    post_record = Post.create!(
      user: owner,
      body: 'edit target',
      post_type: :future,
      is_public: true,
      deadline: Date.current
    )
    sign_in other_user

    patch post_path(post_record), params: {
      post: {
        body: 'updated body'
      }
    }

    expect(response).to redirect_to(posts_path)
    expect(post_record.reload.body).to eq('edit target')
  end

  it '投稿者は自身の投稿を削除できる' do
    post_record = Post.create!(
      user: owner,
      body: 'delete target',
      post_type: :future,
      is_public: true,
      deadline: Date.current
    )
    sign_in owner

    delete post_path(post_record)

    expect(response).to redirect_to(posts_path)
    expect(Post.exists?(post_record.id)).to be(false)
  end
end
