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
      is_public: true,
      deadline: Date.current
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
    expect(response.body).to include('/mypage/records?')
    expect(response.body).to include('from=mypage_records')
  end

  it '未達成フィルターで達成済みのみの月は達成メッセージを表示する' do
    Post.where(user: user, post_type: :future).delete_all
    Post.create!(
      user: user,
      title: '達成した目標',
      body: 'done',
      post_type: :future,
      progress: 100,
      is_public: true,
      deadline: Date.current,
      created_at: Time.zone.now
    )

    get mypage_records_path, params: { todo_filter: 'unachieved' }

    expect(response).to have_http_status(:ok)

    # 新しい達成メッセージ（改行や表現変更に強いように分割）
    expect(response.body).to include('今月は1件の目標を達成しています。')
    expect(response.body).to include('現在未達の目標はありません。')
    expect(response.body).to include('ぜひ新しい目標を立ててみましょう。')

    expect(response.body).to include('未達成のTODOはありません。')
    expect(response.body).not_to include('この月には未来宣言箱の投稿がありません。')
  end
end
