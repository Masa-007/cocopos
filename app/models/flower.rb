# app/models/flower.rb
class Flower < ApplicationRecord
  belongs_to :user
  belongs_to :flowerable, polymorphic: true, counter_cache: true
end
