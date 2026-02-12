# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_many :flowers, as: :flowerable, dependent: :destroy

  validates :content, presence: true
  validate :content_does_not_include_ng_words
  validates :public_uuid, presence: true, uniqueness: true

  before_validation :assign_public_uuid, on: :create

  def to_param
    public_uuid
  end

  # コメントに含まれるNGワードをチェック
  def content_does_not_include_ng_words
    return if content.blank?

    # config/initializers/ng_words.rb で定義した NG_WORDS 配列を読み込む
    ng_words = defined?(NG_WORDS) ? NG_WORDS : []
    matched_words = ng_words.select { |word| content.include?(word) }

    errors.add(:content, "に使用できない単語が含まれています: #{matched_words.join(', ')}") if matched_words.any?

    url_regex = %r{https?://\S+|www\.\S+}
    errors.add(:content, 'にURLが含まれています') if content.match?(url_regex)

    email_regex = /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/i
    errors.add(:content, 'にメールアドレスが含まれています') if content.match?(email_regex)
  end

  # いいね（花）の数を返す
  def flower_count
    self[:flowers_count] || 0
  end

  # 指定ユーザーが花をつけたかどうか
  def flowered_by?(user)
    return false unless user

    if flowers.loaded?
      flowers.any? { |flower| flower.user_id == user.id }
    else
      flowers.exists?(user_id: user.id)
    end
  end

  private

  def assign_public_uuid
    self.public_uuid ||= SecureRandom.uuid
  end
end
