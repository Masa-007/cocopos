# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :flowers, as: :flowerable, dependent: :destroy

  enum post_type: {
    future: 0,
    organize: 1,
    thanks: 2
  }

  validates :body, presence: true, length: { maximum: 1000 }
  validates :post_type, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :with_opinion, -> { where(opinion_needed: true) }

  def display_name
    if is_anonymous
      '匿名さん'
    else
      user&.name.presence || '名無しユーザー'
    end
  end

  POST_TYPE_INFO = {
    future: { icon: '🌱', name: '未来宣言箱', color: 'green' },
    organize: { icon: '🌈', name: '心の整理箱', color: 'purple' },
    thanks: { icon: '💌', name: '感謝箱', color: 'pink' }
  }.freeze

  def post_type_icon
    POST_TYPE_INFO[post_type.to_sym][:icon]
  end

  def post_type_name
    POST_TYPE_INFO[post_type.to_sym][:name]
  end

  def post_type_color
    POST_TYPE_INFO[post_type.to_sym][:color]
  end

  def flower_count
    self[:flowers_count] || 0
  end

  def flowered_by?(user)
    flowers.exists?(user_id: user.id)
  end
end
