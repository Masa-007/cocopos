# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_many :flowers, as: :flowerable, dependent: :destroy

  validates :content, presence: true

  def flower_count
    self[:flowers_count] || 0
  end

  def flowered_by?(user)
    flowers.exists?(user_id: user.id)
  end
end
