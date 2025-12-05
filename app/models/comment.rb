# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_many :flowers, as: :flowerable, dependent: :destroy

  validates :content, presence: true
  validate :content_does_not_include_ng_words

  # コメントに含まれるNGワードをチェック
  def content_does_not_include_ng_words
    return if content.blank?

    # config/initializers/ng_words.rb で定義した NG_WORDS 配列を読み込む
    ng_words = defined?(NG_WORDS) ? NG_WORDS : []
    matched_words = ng_words.select { |word| content.include?(word) }

    return unless matched_words.any?

    errors.add(:content, "に使用できない単語が含まれています: #{matched_words.join(', ')}")
  end

  # いいね（花）の数を返す
  def flower_count
    self[:flowers_count] || 0
  end

  # 指定ユーザーが花をつけたかどうか
  def flowered_by?(user)
    flowers.exists?(user_id: user.id)
  end
end
