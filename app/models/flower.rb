# frozen_string_literal: true

# app/models/flower.rb
class Flower < ApplicationRecord
  belongs_to :user
  belongs_to :flowerable, polymorphic: true, counter_cache: true

  validates :user_id, uniqueness: { scope: %i[flowerable_type flowerable_id] }
end
