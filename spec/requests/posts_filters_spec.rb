# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '投稿一覧フィルタ', type: :request do
  let(:user) do
    User.create!(
      name: 'Filter User',
      email: "filter_user_#{SecureRandom.hex(4)}@example.com",
      password: 'password'
    )
  end

  before do
    host! 'www.cocopos.net'

    @future_achieved = Post.create!(user:, title: '達成済み', body: 'future achieved', post_type: :future, progress: 100, is_public: true)
    @future_unachieved = Post.create!(user:, title: '未達成', body: 'future unachieved', post_type: :future, progress: 20, is_public: true)
    @organize_happy = Post.create!(user:, title: '嬉しい日', body: 'organize happy', post_type: :organize, mood: :happy, is_public: true)
    @thanks_friend = Post.create!(user:, title: '友人に感謝', body: 'thanks friend', post_type: :thanks, thanks_recipient: :friend, is_public: true)
    @private_post = Post.create!(user:, title: '非公開', body: 'private body', post_type: :future, is_public: false)
  end

  it 'デフォルトでは公開投稿のみを表示する' do
    get posts_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('future achieved')
    expect(response.body).to include('future unachieved')
    expect(response.body).to include('organize happy')
    expect(response.body).not_to include('private body')
  end

  it 'future + future_achieved で進捗100のみ表示する' do
    get posts_path, params: { filter: 'future', sub_filter: 'future_achieved' }

    expect(response.body).to include('future achieved')
    expect(response.body).not_to include('future unachieved')
  end

  it 'future + future_unachieved で未達成のみ表示する' do
    get posts_path, params: { filter: 'future', sub_filter: 'future_unachieved' }

    expect(response.body).to include('future unachieved')
    expect(response.body).not_to include('future achieved')
  end

  it 'organize + moodサブフィルタで対象の気分のみ表示する' do
    get posts_path, params: { filter: 'organize', sub_filter: 'happy' }

    expect(response.body).to include('organize happy')
    expect(response.body).not_to include('future achieved')
  end

  it 'thanks + recipientサブフィルタで対象のみ表示する' do
    get posts_path, params: { filter: 'thanks', sub_filter: 'friend' }

    expect(response.body).to include('thanks friend')
    expect(response.body).not_to include('organize happy')
  end

  it 'q検索でtitle/bodyを部分一致検索できる' do
    get posts_path, params: { q: '達成済み' }

    expect(response.body).to include('future achieved')
    expect(response.body).not_to include('future unachieved')
  end
end
