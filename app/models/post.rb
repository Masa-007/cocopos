# frozen_string_literal: true

require Rails.root.join("config/initializers/ng_words")

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
  validate :body_does_not_contain_ng_words

  scope :recent, -> { order(created_at: :desc) }
  scope :with_opinion, -> { where(comment_allowed: true) }

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

  private

  # NGワードやURL・電話番号を含まないか検証
  def body_does_not_contain_ng_words
    return if body.blank?

    # NGワードチェック
    NG_WORDS.each do |word|
      if body.include?(word)
        errors.add(:body, "に禁止されている単語が含まれています: #{word}")
        break
      end
    end

    # URLチェック
    url_regex = %r{https?://[\S]+|www\.[\S]+}
    if body.match?(url_regex)
      errors.add(:body, "にURLが含まれています")
    end

    # 電話番号チェック（簡易）
    phone_regex = /0\d{1,4}[-\s]?\d{1,4}[-\s]?\d{4}/
    if body.match?(phone_regex)
      errors.add(:body, "に電話番号が含まれています")
    end
  end
end
