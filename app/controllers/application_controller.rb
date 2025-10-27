class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_season 

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  private

  # 季節クラスをセット
  def set_season
    month = Time.zone.now.month
    @season =
      case month
      when 3..5
        "spring"
      when 6..8
        "summer"
      when 9..11
        "autumn"
      else
        "winter"
      end
  end
end
