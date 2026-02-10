# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include Devise::Controllers::Rememberable

    def google_oauth2
      handle_auth("Google")
    end

    def failure
      redirect_to new_user_session_path,
                  alert: t("devise.omniauth_callbacks.failure",
                           kind: "Google",
                           reason: failure_message)
    end

    private

    def handle_auth(kind)
      @user = User.from_omniauth(request.env["omniauth.auth"])

      if @user.persisted?
        set_flash_message(:notice, :success, kind: kind) if is_navigational_format?

        sign_in @user, event: :authentication
        remember_me(@user) # Googleログインは常に保持

        redirect_to mypage_path
      else
        session["devise.#{kind.downcase}_data"] = request.env["omniauth.auth"].except("extra")
        redirect_to new_user_registration_url, alert: @user.errors.full_messages.to_sentence
      end
    end
  end
end
