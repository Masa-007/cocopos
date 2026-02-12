# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'マイページ記録', type: :request do
  let(:user) do
    User.create!(
      name: 'Records User',
      email: "records_user_#{SecureRandom.hex(4)}@example.com",
      password: 'password'
    )
  end

  before do
    Post.create!(
      user: user,
      title: '未来の目標',
      body: 'future body',
      post_type: :future,
      progress: 20,
      is_public: true
    )

    Post.create!(
      user: user,
      title: '今日の気分',
      body: 'organize body',
      post_type: :organize,
      mood: :happy,
      is_public: true
    )

    Post.create!(
      user: user,
      title: 'ありがとう',
      body: 'thanks body',
      post_type: :thanks,
      thanks_recipient: :friend,
      is_public: true
    )

    host! 'www.cocopos.net'
    sign_in user
  end

  it 'これまでの記録ページに主要な振り返り要素が表示される' do
    get mypage_records_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('これまでの記録')
    expect(response.body).to include('未来宣言箱のTODOメモ')
    expect(response.body).to include('あなたの気分メーター')
    expect(response.body).to include('感謝箱の積み重ね')
    expect(response.body).to include('今月の投稿数')
    expect(response.body).to include('連続投稿日数')
  end
end
