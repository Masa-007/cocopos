# app/models/post.rb
class Post < ApplicationRecord
  # アソシエーション
  belongs_to :user
  has_many :comments, dependent: :destroy

  # Enum定義
  enum post_type: {
    future: 0,     # 🌱 未来宣言箱
    organize: 1,   # 🌈 心の整理箱
    thanks: 2      # 💌 感謝箱
  }

  # バリデーション
  validates :body, presence: true, length: { minimum: 1, maximum: 1000 }
  validates :post_type, presence: true

  # スコープ
  scope :recent, -> { order(created_at: :desc) }
  scope :with_opinion, -> { where(opinion_needed: true) }

  # メソッド
  def display_name
    is_anonymous ? "匿名さん" : user.name
  end

  def post_type_icon
    case post_type
    when "future"
      "🌱"
    when "organize"
      "🌈"
    when "thanks"
      "💌"
    end
  end

def post_type_icon
  case post_type.to_sym
  when :future
    "🌱"
  when :organize
    "🌈"
  when :thanks
    "💌"
  end
end

def post_type_name
  case post_type.to_sym
  when :future
    "未来宣言箱"
  when :organize
    "心の整理箱"
  when :thanks
    "感謝箱"
  end
end

def post_type_color
  case post_type.to_sym
  when :future
    "green"
  when :organize
    "purple"
  when :thanks
    "pink"end
  end
end
