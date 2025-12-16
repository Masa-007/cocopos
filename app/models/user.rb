# frozen_string_literal: true

class User < ApplicationRecord
  # Deviseモジュール
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # アソシエーション
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :flowers, dependent: :destroy

  # バリデーション
  validates :name, presence: true, length: { maximum: 50 }

  # 管理者フラグ
  def admin?
    admin
  end

  # 表示名（匿名対応）
  def display_name
    name.presence || '匿名ユーザー'
  end

  # 🤖 AI文章生成：1日1回のみ利用可
  def ai_available_today?
    return true if last_ai_used_at.nil?

    last_ai_used_at < Time.current.beginning_of_day
  end

  # 🤖 本日のAI残り利用回数（表示用）
  def ai_remaining_count
    ai_available_today? ? 1 : 0
  end
end
