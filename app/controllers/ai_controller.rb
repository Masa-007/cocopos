# frozen_string_literal: true

class AiController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_organize_post!
  before_action :ensure_ai_available_today!
  before_action :ensure_rate_limit!

  def generate_text
    result = Openai::GenerateText.call(
      prompt: params[:prompt]
    )

    if result.success?
      # AI利用確定（成功時のみ消費）
      current_user.update!(last_ai_used_at: Time.current)

      render json: {
        options: result.options
      }, status: :ok
    else
      render json: { error: result.error },
             status: :unprocessable_entity
    end
  end

  private

  # 心の整理箱のみ許可
  def ensure_organize_post!
    return if params[:post_type] == "organize"

    render json: {
      error: "AI本文補助は心の整理箱のみ利用できます"
    }, status: :forbidden
  end

  # 1日1回制限（ユーザー単位）
  def ensure_ai_available_today!
    return if current_user.ai_available_today?

    render json: {
      error: "本日のAI利用回数を超えています"
    }, status: :forbidden
  end

  # IP + User の簡易レート制限（荒らし対策）
  def ensure_rate_limit!
    key = "ai:rate_limit:#{current_user.id}:#{request.remote_ip}"
    count = Rails.cache.read(key).to_i

    if count >= 3
      render json: {
        error: "短時間でのAI利用が制限されています"
      }, status: :too_many_requests
      return
    end

    Rails.cache.write(key, count + 1, expires_in: 10.minutes)
  end
end

