# frozen_string_literal: true

class Flower < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true
end
