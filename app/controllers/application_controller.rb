# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_default_meta
  before_action :set_season

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  private

  def set_default_meta
    @page_title = 'cocopos - 心のポスト'
    @page_description = '心の記録を花のように咲かせる。未来宣言箱・心の整理箱・感謝箱で気持ちを残せるアプリです。'
    @page_image_path = 'cocopos.ogp.jpg'
    @page_type = 'website'
  end

  # 季節クラスをセット
  def set_season
    month = Time.zone.now.month
    @season = case month
              when 3..5 then 'spring'
              when 6..8 then 'summer'
              when 9..11 then 'autumn'
              else 'winter'
              end
  end
end
