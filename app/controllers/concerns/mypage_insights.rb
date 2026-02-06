# frozen_string_literal: true

module MypageInsights
  extend ActiveSupport::Concern

  included do
    include MypageInsights::Future
    include MypageInsights::Mood
    include MypageInsights::Thanks
  end
end
