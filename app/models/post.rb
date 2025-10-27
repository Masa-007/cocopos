# frozen_string_literal: true

# app/models/post.rb
class Post < ApplicationRecord
  # === アソシエーション ===
  belongs_to :user
  has_many :comments, dependent: :destroy

  # === Enum定義 ===
  enum post_type: {
    future: 0,     # 🌱 未来宣言箱
    organize: 1,   # 🌈 心の整理箱
    thanks: 2      # 💌 感謝箱
  }

  # === バリデーション ===
  validates :body, presence: true, length: { maximum: 1000 }
  validates :post_type, presence: true

  # === スコープ ===
  scope :recent, -> { order(created_at: :desc) }
  scope :with_opinion, -> { where(opinion_needed: true) }

  # === インスタンスメソッド ===

  # 投稿者名（匿名対応）
  def display_name
    is_anonymous ? '匿名さん' : user.name
  end

  # 投稿タイプごとの設定をまとめて定義
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
end
