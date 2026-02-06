# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it '名前がない場合は無効である' do
    user = described_class.new(email: "no_name#{SecureRandom.hex(4)}@example.com", password: 'password', name: nil)

    expect(user).not_to be_valid
    expect(user.errors[:name]).to include('を入力してください')
  end

  it 'display_nameはnameを返す' do
    user = described_class.new(name: 'Alice')

    expect(user.display_name).to eq('Alice')
  end

  it 'last_ai_used_atに応じて本日のAI残回数を返す' do
    user = described_class.new(last_ai_used_at: nil)
    expect(user.ai_remaining_count).to eq(1)

    user.last_ai_used_at = Time.current
    expect(user.ai_remaining_count).to eq(0)
  end

  it 'adminフラグがtrueならadmin?はtrueを返す' do
    user = described_class.new(admin: true)

    expect(user.admin?).to be(true)
  end

  describe '.from_omniauth' do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid: 'uid-123',
        info: {
          email: "oauth#{SecureRandom.hex(4)}@example.com",
          name: 'OAuth User'
        }
      )
    end

    it '一致ユーザーがいない場合は新規ユーザーを作成する' do
      user = described_class.from_omniauth(auth)

      expect(user).to be_persisted
      expect(user.provider).to eq('google_oauth2')
      expect(user.uid).to eq('uid-123')
      expect(user.email).to eq(auth.info.email)
      expect(user.name).to eq('OAuth User')
    end

    it 'メール一致の既存ユーザーがいる場合は再利用する' do
      existing = described_class.create!(name: 'Existing', email: auth.info.email, password: 'password')

      user = described_class.from_omniauth(auth)

      expect(user.id).to eq(existing.id)
      expect(user.provider).to eq('google_oauth2')
      expect(user.uid).to eq('uid-123')
      expect(user.name).to eq('Existing')
    end
  end

  describe '#ai_available_today?' do
    it 'last_ai_used_atが当日より前ならtrueを返す' do
      user = described_class.new(last_ai_used_at: 1.day.ago.beginning_of_day)

      expect(user.ai_available_today?).to be(true)
    end
  end
end
