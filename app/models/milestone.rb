# app/models/milestone.rb
# frozen_string_literal: true

class Milestone < ApplicationRecord
  belongs_to :post

  validates :title, presence: true, length: { maximum: 100 }

  # future 専用
  validate :post_must_be_future

  private

  def post_must_be_future
    return if post&.future?

    errors.add(:base, '小目標は未来宣言箱のみ設定できます')
  end
end
