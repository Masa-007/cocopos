# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Milestone, type: :model do
  let(:user) do
    User.create!(name: 'Taro', email: "milestone_user_#{SecureRandom.hex(4)}@example.com", password: 'password')
  end

  it '未来宣言箱の投稿に対して、タイトルが設定されていれば Milestone は有効である' do
    post_record = Post.create!(user:, body: '未来投稿', post_type: :future)
    milestone = described_class.new(post: post_record, title: '最初の目標')
    expect(milestone).to be_valid
  end

  it 'タイトルが存在しない場合、Milestone は無効になる' do
    post_record = Post.create!(user:, body: '未来投稿', post_type: :future)
    milestone = described_class.new(post: post_record, title: nil)
    expect(milestone).not_to be_valid
    expect(milestone.errors[:title]).to include('を入力してください')
  end

  it '未来宣言箱以外の投稿には Milestone を設定できない' do
    post_record = Post.create!(user:, body: '整理投稿', post_type: :organize, mood: :calm)
    milestone = described_class.new(post: post_record, title: '目標')
    expect(milestone).not_to be_valid
    expect(milestone.errors[:base]).to include('小目標は未来宣言箱のみ設定できます')
  end
end
