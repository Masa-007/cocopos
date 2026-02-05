# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flower, type: :model do
  let(:user) { User.create!(name: 'FlowerUser', email: "flower#{SecureRandom.hex(4)}@example.com", password: 'password') }
  let(:post_record) { Post.create!(user:, body: '花を受け取る投稿', post_type: :future) }

  it 'is valid with user and flowerable' do
    flower = described_class.new(user:, flowerable: post_record)

    expect(flower).to be_valid
  end
end