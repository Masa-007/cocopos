# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flower, type: :model do
  it '同一ユーザーが同一対象へ重複して花を付けられない' do
    user = User.create!(name: 'Uniq User', email: "flower_uniq_#{SecureRandom.hex(4)}@example.com",
                        password: 'password')
    owner = User.create!(name: 'Owner User', email: "flower_owner2_#{SecureRandom.hex(4)}@example.com",
                         password: 'password')
    post_record = Post.create!(user: owner, body: 'body', post_type: :future, is_public: true, deadline: Date.current)

    described_class.create!(user: user, flowerable: post_record)
    duplicate = described_class.new(user: user, flowerable: post_record)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:user_id]).to be_present
  end
end
