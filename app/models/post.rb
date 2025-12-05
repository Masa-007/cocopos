# frozen_string_literal: true

require Rails.root.join('config/initializers/ng_words')

class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :flowers, as: :flowerable, dependent: :destroy

  enum post_type: {
    future: 0,
    organize: 1,
    thanks: 2
  }

  # 気分一覧（スコア付き）
  MOODS = {
    excited: { label: '🤩 ワクワク', score: 5 },
    happy: { label: '😊 嬉しい', score: 4 },
    calm: { label: '😌 穏やか', score: 3 },
    tired: { label: '😴 疲れた', score: 2 },
    frustrated: { label: '😣 モヤモヤ', score: 2 },
    sad: { label: '😔 悲しい', score: 1 },
    anxious: { label: '😰 不安',       score: 1 },
    angry: { label: '😡 怒り', score: 1 }
  }.freeze

  validates :body, presence: true, length: { maximum: 1000 }
  validates :post_type, presence: true

  # organize のとき mood 必須
  validates :mood, presence: true, if: -> { post_type == 'organize' }

  validate :body_does_not_contain_ng_words

  scope :recent, -> { order(created_at: :desc) }
  scope :with_opinion, -> { where(comment_allowed: true) }

  # 🌈 投稿者名（匿名対応）
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

  before_save :assign_mood_score

  # 気分に応じた数値スコアを保存
  def assign_mood_score
    return if mood.blank? # mood 空ならスキップ
    return unless MOODS[mood.to_sym] # 未定義 mood 防止

    self.mood_score = MOODS[mood.to_sym][:score]
  end

  private

  # NGワードやURL・電話番号チェック
  def body_does_not_contain_ng_words
    return if body.blank?

    NG_WORDS.each do |word|
      if body.include?(word)
        errors.add(:body, "に禁止されている単語が含まれています: #{word}")
        break
      end
    end

    url_regex = %r{https?://\S+|www\.\S+}
    errors.add(:body, 'にURLが含まれています') if body.match?(url_regex)

    phone_regex = /0\d{1,4}[-\s]?\d{1,4}[-\s]?\d{4}/
    return unless body.match?(phone_regex)

    errors.add(:body, 'に電話番号が含まれています')
  end
end
