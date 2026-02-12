# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :flowers, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }, uniqueness: { case_sensitive: true } # rubocop:disable Rails/UniqueValidationWithoutIndex

  def admin?
    admin
  end

  def display_name
    name.presence || '匿名ユーザー'
  end

  def ai_available_today?
    return true if last_ai_used_at.nil?

    last_ai_used_at < Time.current.beginning_of_day
  end

  def ai_remaining_count
    ai_available_today? ? 1 : 0
  end

  def self.from_omniauth(auth)
    user = find_or_initialize_from_auth(auth)
    apply_auth_attributes(user, auth)
    ensure_password(user)

    user.save
    user
  end

  class << self
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
