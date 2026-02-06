# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'マイページ投稿一覧', type: :request do
  let(:user) do
    User.create!(
      name: 'Mypage User',
      email: "mypage_user_#{SecureRandom.hex(4)}@example.com",
      password: 'password'
    )
  end

  let!(:future_achieved) do
    Post.create!(
      user: user,
      title: '達成済み',
      body: 'future achieved body',
      post_type: :future,
      progress: 100,
      is_public: true
    )
  end

  let!(:future_unachieved) do
    Post.create!(
      user: user,
      title: '未達成',
      body: 'future unachieved body',
      post_type: :future,
      progress: 10,
      is_public: true
    )
  end

  before do
    Post.create!(
      user: user,
      title: '嬉しい整理',
      body: 'organize happy body',
      post_type: :organize,
      mood: :happy,
      is_public: true
    )

    Post.create!(
      user: user,
      title: '友人へ感謝',
      body: 'thanks friend body',
      post_type: :thanks,
      thanks_recipient: :friend,
      is_public: true
    )

    Post.create!(
      user: user,
      title: '非公開投稿',
      body: 'private body',
      post_type: :future,
      is_public: false
    )

    host! 'www.cocopos.net'
    sign_in user
  end

  it 'privateフィルタで非公開投稿のみ表示する' do
    get mypage_posts_path, params: { filter: 'private' }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('private body')
    expect(response.body).not_to include('future achieved body')
  end

  it 'future + achievedフィルタで達成済みのみ表示する' do
    get mypage_posts_path, params: { filter: 'future', sub_filter: 'future_achieved' }

    expect(response.body).to include('future achieved body')
    expect(response.body).not_to include('future unachieved body')
  end

  it 'future + unachievedフィルタで未達成のみ表示する' do
    get mypage_posts_path, params: { filter: 'future', sub_filter: 'future_unachieved' }

    expect(response.body).to include('future unachieved body')
    expect(response.body).not_to include('future achieved body')
  end

  it 'organize + moodフィルタで対象の気分のみ表示する' do
    get mypage_posts_path, params: { filter: 'organize', sub_filter: 'happy' }

    expect(response.body).to include('organize happy body')
    expect(response.body).not_to include('thanks friend body')
  end

  it 'thanks + recipientフィルタで対象のみ表示する' do
    get mypage_posts_path, params: { filter: 'thanks', sub_filter: 'friend' }

    expect(response.body).to include('thanks friend body')
    expect(response.body).not_to include('organize happy body')
  end

  it 'q検索で本文を部分一致検索できる' do
    get mypage_posts_path, params: { q: 'unachieved' }

    expect(response.body).to include('future unachieved body')
    expect(response.body).not_to include('future achieved body')
  end

  it 'sort=oldで古い順に並ぶ' do
    future_achieved.update!(created_at: 2.days.ago)
    future_unachieved.update!(created_at: 1.day.ago)

    get mypage_posts_path, params: { filter: 'future', sort: 'old' }

    idx_old = response.body.index('future achieved body')
    idx_new = response.body.index('future unachieved body')

    expect(idx_old).to be < idx_new
  end
end
