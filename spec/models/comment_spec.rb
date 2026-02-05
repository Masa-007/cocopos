# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:user) { User.create!(name: 'Hanako', email: "hanako#{SecureRandom.hex(4)}@example.com", password: 'password') }
  let(:post_record) { Post.create!(user:, body: '投稿本文', post_type: :future) }

  it 'contentがあれば有効である' do
    comment = described_class.new(user:, post: post_record, content: 'コメントです')

    expect(comment).to be_valid
  end

  it 'contentにNGワードが含まれている場合は無効になる' do
    comment = described_class.new(user:, post: post_record, content: '暴力的なコメントです')

    expect(comment).not_to be_valid
    expect(comment.errors[:content].join).to include('使用できない単語')
  end

  it '作成時にpublic_uuidが自動で付与される' do
    comment = described_class.create!(user:, post: post_record, content: 'UUID付き')

    expect(comment.public_uuid).to be_present
  end

  it 'to_paramはpublic_uuidを返す' do
    comment = described_class.create!(user:, post: post_record, content: 'param')

    expect(comment.to_param).to eq(comment.public_uuid)
  end

  it 'flower_countはnilの場合に0を返す' do
    comment = described_class.create!(user:, post: post_record, content: 'flower')

    expect(comment.flower_count).to eq(0)
  end

  it 'flowered_by?は指定ユーザーの花有無を判定する' do
    comment = described_class.create!(user:, post: post_record, content: 'flowered')
    another_user = User.create!(name: 'Taro', email: "taro#{SecureRandom.hex(4)}@example.com", password: 'password')
    Flower.create!(user: another_user, flowerable: comment)

    expect(comment.flowered_by?(another_user)).to be(true)
    expect(comment.flowered_by?(user)).to be(false)
  end
end
