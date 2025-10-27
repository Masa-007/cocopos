# frozen_string_literal: true

class User < ApplicationRecord
  # Deviseモジュール
  # :confirmable, :lockable, :timeoutable, :trackable, :omniauthable なども必要に応じて追加可能
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # アソシエーション
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  # バリデーション
  validates :name, presence: true, length: { maximum: 50 }
end
