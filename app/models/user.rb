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
  # migrationで追加: add_column :users, :admin, :boolean, default: false, null: false
  def admin?
    admin
  end

  # 表示名（匿名対応）
  def display_name
    name.presence || '匿名ユーザー'
  end
end
