# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { User.create!(name: 'Taro', email: "user#{SecureRandom.hex(4)}@example.com", password: 'password') }

  describe 'validations' do
    it 'future投稿は必須項目が揃っていれば有効である' do
      post = described_class.new(user:, body: '未来に向けて頑張る', post_type: :future)

      expect(post).to be_valid
    end

    it 'organize投稿ではmoodが必須である' do
      post = described_class.new(user:, body: '心を整理する', post_type: :organize, mood: nil)

      expect(post).not_to be_valid
      expect(post.errors[:mood]).to be_present
    end

    it 'thanks投稿ではthanks_recipientが必須である' do
      post = described_class.new(user:, body: 'ありがとう', post_type: :thanks, thanks_recipient: nil)

      expect(post).not_to be_valid
      expect(post.errors[:thanks_recipient]).to be_present
    end

    it 'future投稿で過去の日付のdeadlineは無効である' do
      post = described_class.new(user:, body: '明日からやる', post_type: :future, deadline: Date.yesterday)

      expect(post).not_to be_valid
      expect(post.errors[:deadline]).to include('は今日以降の日付を指定してください')
    end

    it 'bodyにNGワードが含まれている場合は無効になる' do
      post = described_class.new(user:, body: 'これは暴力を含む文です', post_type: :future)

      expect(post).not_to be_valid
      expect(post.errors[:body].join).to include('禁止されている単語')
    end

    it 'bodyにURLが含まれている場合は無効になる' do
      post = described_class.new(user:, body: '詳細は https://example.com を見て', post_type: :future)

      expect(post).not_to be_valid
      expect(post.errors[:body]).to include('にURLが含まれています')
    end

    it 'future以外の投稿では小目標を設定できない' do
      post = described_class.new(user:, body: '整理', post_type: :organize)
      post.milestones.build(title: '小目標')

      expect(post).not_to be_valid
      expect(post.errors[:base]).to include('小目標は未来宣言箱のみ設定できます')
    end
  end

  describe 'instance methods' do
    it '投稿タイプに対応するメタ情報を返す' do
      post = described_class.new(user:, body: '未来', post_type: :future)

      expect(post.post_type_icon).to eq('🌱')
      expect(post.post_type_name).to eq('未来宣言箱')
      expect(post.post_type_color).to eq('green')
    end

    it '匿名投稿の場合はデフォルトの表示名を返す' do
      post = described_class.new(user:, body: '本文', post_type: :future, is_anonymous: true)

      expect(post.display_name).to eq('匿名さん')
    end

    it '匿名でない場合はユーザー名を表示名として返す' do
      post = described_class.new(user:, body: '本文', post_type: :future, is_anonymous: false)

      expect(post.display_name).to eq('Taro')
    end

    it 'thanks投稿でその他を選択した場合は詳細付きタグを返す' do
      post = described_class.new(
        user:,
        body: 'ありがとう',
        post_type: :thanks,
        thanks_recipient: :other,
        thanks_recipient_other: '先生'
      )

      expect(post.thanks_recipient_tag).to eq('#その他（先生）')
    end

    it '保存時にmoodからmood_scoreが設定される' do
      post = described_class.create!(user:, body: '整理する', post_type: :organize, mood: :happy)

      expect(post.mood_score).to eq(4)
    end
  end

  describe 'scopes' do
    it '新しい投稿順に並んだレコードを返す' do
      old_post = described_class.create!(user:, body: 'old', post_type: :future, created_at: 2.days.ago)
      new_post = described_class.create!(user:, body: 'new', post_type: :future, created_at: 1.day.ago)

      expect(described_class.recent.first).to eq(new_post)
      expect(described_class.recent.last).to eq(old_post)
    end

    it 'コメント可能な投稿のみを返す' do
      visible = described_class.create!(user:, body: 'with opinion', post_type: :future, comment_allowed: true)
      described_class.create!(user:, body: 'without opinion', post_type: :future, comment_allowed: false)

      expect(described_class.with_opinion).to contain_exactly(visible)
    end
  end
end
