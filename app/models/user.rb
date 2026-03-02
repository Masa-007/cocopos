# frozen_string_literal: true

class User < ApplicationRecord
  DEFAULT_AI_DAILY_LIMIT = 1
  DEMO_AI_DAILY_LIMIT = 3

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :flowers, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }, uniqueness: { case_sensitive: true }

  def admin?
    admin
  end

  def display_name
    name.presence || '匿名ユーザー'
  end

  def ai_available_today?
    ai_remaining_count.positive?
  end

  def ai_daily_limit
    demo_account? ? DEMO_AI_DAILY_LIMIT : DEFAULT_AI_DAILY_LIMIT
  end

  def ai_used_count_today
    return ai_used_count if ai_used_on == Date.current

    # Backward compatibility: records created before counter columns
    return 1 if last_ai_used_at&.to_date == Date.current

    0
  end

  def ai_remaining_count
    [ai_daily_limit - ai_used_count_today, 0].max
  end

  def consume_ai_usage!
    today = Date.current
    used_count = ai_used_on == today ? ai_used_count : 0

    update!(
      ai_used_on: today,
      ai_used_count: used_count + 1,
      last_ai_used_at: Time.current
    )
  end

  def demo_account?
    self.class.demo_account_emails.include?(email.to_s.downcase)
  end

  def self.from_omniauth(auth)
    user = find_or_initialize_from_auth(auth)
    apply_auth_attributes(user, auth)
    ensure_password(user)

    user.save
    user
  end

  class << self
    def demo_account_emails
      configured_emails = ENV.fetch('DEMO_ACCOUNT_EMAILS', 'cocopos.demo@example.com')
      configured_emails.split(',').map { |value| value.strip.downcase }.compact_blank
    end

    private

    def find_or_initialize_from_auth(auth)
      find_by(provider: auth.provider, uid: auth.uid) ||
        find_by(email: auth.info.email) ||
        new
    end

    def apply_auth_attributes(user, auth)
      user.provider ||= auth.provider
      user.uid ||= auth.uid
      user.email ||= auth.info.email
      user.name ||= derive_name_from_auth(auth)
      user
    end

    def derive_name_from_auth(auth)
      auth.info.name.presence ||
        auth.info.email&.split('@')&.first ||
        'Googleユーザー'
    end

    def ensure_password(user)
      return if user.encrypted_password.present?

      user.password ||= Devise.friendly_token[0, 20]
    end
  end
end
