# frozen_string_literal: true

require Rails.root.join('config/initializers/ng_words')

class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :flowers, as: :flowerable, dependent: :destroy
  has_many :milestones, dependent: :destroy

  accepts_nested_attributes_for :milestones, allow_destroy: true

  enum post_type: {
    future: 0,
    organize: 1,
    thanks: 2
  }
  THANKS_RECIPIENTS = {
    family: '家族',
    friend: '友人',
    partner: '恋人',
    work: '仕事',
    self: '自分',
    other: 'その他'
  }.freeze

  attribute :thanks_recipient, :integer

  enum thanks_recipient: {
    family: 0,
    friend: 1,
    partner: 2,
    work: 3,
    self: 4,
    other: 5
  }, _prefix: :thanks_recipient

  MOODS = {
    excited: { label: '🤩 ワクワク', score: 5 },
    happy: { label: '😊 嬉しい', score: 4 },
    calm: { label: '😌 穏やか', score: 3 },
    tired: { label: '😴 疲れた', score: 2 },
    frustrated: { label: '😣 モヤモヤ', score: 2 },
    sad: { label: '😔 悲しい', score: 1 },
    anxious: { label: '😰 不安', score: 1 },
    angry: { label: '😡 怒り', score: 1 }
  }.freeze

  validates :body, presence: true, length: { maximum: 1000 }
  validates :post_type, presence: true
  validates :public_uuid, presence: true, uniqueness: true

  validates :thanks_recipient_other, presence: true, if: :thanks_recipient_other?

  validates :progress,
            numericality: { only_integer: true, in: 0..100 },
            allow_nil: true,
            if: :future?

  validate :mood_presence_for_organize
  validate :thanks_recipient_presence_for_thanks

  validate :deadline_cannot_be_in_the_past, if: :future?
  validate :milestones_only_for_future
  validate :milestones_limit, if: :future?
  validate :body_does_not_contain_ng_words

  scope :recent, -> { order(created_at: :desc) }
  scope :with_opinion, -> { where(comment_allowed: true) }

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

  def thanks_recipient_tag
    return unless thanks?
    return unless thanks_recipient

    label = THANKS_RECIPIENTS[thanks_recipient.to_sym]
    return "##{label}" unless thanks_recipient_other?

    detail = thanks_recipient_other.to_s.strip
    return "##{label}" if detail.blank?

    "##{label}（#{detail}）"
  end

  def display_name
    if is_anonymous
      '匿名さん'
    else
      user&.name.presence || '名無しユーザー'
    end
  end

  def to_param
    public_uuid
  end

  def flower_count
    self[:flowers_count] || 0
  end

  def flowered_by?(user)
    flowers.exists?(user_id: user.id)
  end
  before_validation :assign_public_uuid, on: :create
  before_save :assign_mood_score

  def assign_mood_score
    return if mood.blank?
    return unless MOODS[mood.to_sym]

    self.mood_score = MOODS[mood.to_sym][:score]
  end

  def future?
    post_type == 'future'
  end

  def organize?
    post_type == 'organize'
  end

  def thanks_recipient_other?
    thanks_recipient == 'other'
  end

  def mood_presence_for_organize
    return unless organize?
    return if mood.present?

    errors.add(:mood, 'を選択してください')
  end

  def thanks_recipient_presence_for_thanks
    return unless thanks?
    return if thanks_recipient.present?

    errors.add(:thanks_recipient, 'を選択してください')
  end

  private

  def assign_public_uuid
    self.public_uuid ||= SecureRandom.uuid
  end

  def deadline_cannot_be_in_the_past
    return if deadline.blank?
    return unless deadline < Date.current

    errors.add(:deadline, 'は今日以降の日付を指定してください')
  end

  def milestones_only_for_future
    return if milestones.empty?
    return if future?

    errors.add(:base, '小目標は未来宣言箱のみ設定できます')
  end

  def milestones_limit
    active_count = milestones.reject(&:marked_for_destruction?).size
    return if active_count <= 10

    errors.add(:base, 'マイルストーンは最大10個までです')
  end

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

    email_regex = /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/i
    errors.add(:body, 'にメールアドレスが含まれています') if body.match?(email_regex)

    phone_regex = /0\d{1,4}[-\s]?\d{1,4}[-\s]?\d{4}/
    errors.add(:body, 'に電話番号が含まれています') if body.match?(phone_regex)
  end
end
