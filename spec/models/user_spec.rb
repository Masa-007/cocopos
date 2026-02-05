# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is invalid without name' do
    user = described_class.new(email: "no_name#{SecureRandom.hex(4)}@example.com", password: 'password', name: nil)

    expect(user).not_to be_valid
    expect(user.errors[:name]).to include('を入力してください')
  end

  it 'returns display_name from name' do
    user = described_class.new(name: 'Alice')

    expect(user.display_name).to eq('Alice')
  end

  it 'returns remaining ai count based on last_ai_used_at' do
    user = described_class.new(last_ai_used_at: nil)
    expect(user.ai_remaining_count).to eq(1)

    user.last_ai_used_at = Time.current
    expect(user.ai_remaining_count).to eq(0)
  end
end
