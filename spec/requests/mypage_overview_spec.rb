# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'マイページ表示', type: :request do
  let(:user) do
    User.create!(
      name: 'Mypage User',
      email: "mypage_overview_#{SecureRandom.hex(4)}@example.com",
      password: 'password'
    )
  end

  before do
    host! 'www.cocopos.net'
    sign_in user
  end

  it 'マイページには重複する振り返りセクションを出さない' do
    get mypage_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('これまでの記録')
    expect(response.body).not_to include('未来宣言箱のTODOメモ')
    expect(response.body).not_to include('あなたの気分メーター')
    expect(response.body).not_to include('感謝箱の積み重ね')
  end
end
