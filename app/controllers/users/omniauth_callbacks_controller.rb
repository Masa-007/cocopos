# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    GOOGLE_REAUTH_SESSION_KEY = 'google_reauth_passed_at'
    GOOGLE_REAUTH_FLOW_KEY = 'google_reauth_flow'
    GOOGLE_REAUTH_USER_ID_KEY = 'google_reauth_user_id'

    def google_oauth2
      user = find_user_from_google

      return handle_unpersisted_user(user) unless user.persisted?
      return handle_google_reauth(user) if reauth_flow_for_target_user?(user)

      handle_google_login(user)
    end

    def failure
      redirect_to new_user_session_path,
                  alert: t('devise.omniauth_callbacks.failure',
                           kind: 'Google',
                           reason: failure_message)
    end

    private

    def find_user_from_google
      User.from_omniauth(request.env['omniauth.auth'])
    end

    def omniauth_auth
      request.env['omniauth.auth']
    end

    def handle_unpersisted_user(user)
      clear_google_reauth_flow!
      session['devise.google_data'] = omniauth_auth.except('extra')
      redirect_to new_user_registration_url, alert: user.errors.full_messages.to_sentence
    end

    def handle_google_reauth(user)
      session[GOOGLE_REAUTH_SESSION_KEY] = Time.current.to_i
      clear_google_reauth_flow!
      sign_in_and_restore_remember!(user)

      redirect_to edit_user_registration_path, notice: t('devise.registrations.google_reauth_success')
    end

    def handle_google_login(user)
      clear_google_reauth_flow!
      set_flash_message(:notice, :success, kind: 'Google') if is_navigational_format?
      sign_in_and_restore_remember!(user)

      redirect_to mypage_path
    end

    def sign_in_and_restore_remember!(user)
      sign_in(user, event: :authentication)
      force_remember_me_cookie!(user)
    end

    # current_user に依存しない（OAuth往復で current_user が空になっても判定できる）
    def reauth_flow_for_target_user?(authed_user)
      return false unless session[GOOGLE_REAUTH_FLOW_KEY] == true

      target_user_id = session[GOOGLE_REAUTH_USER_ID_KEY].to_i
      target_user_id.positive? && authed_user.id == target_user_id
    end

    def clear_google_reauth_flow!
      session.delete(GOOGLE_REAUTH_FLOW_KEY)
      session.delete(GOOGLE_REAUTH_USER_ID_KEY)
    end

    def force_remember_me_cookie!(user)
      return unless user.respond_to?(:remember_me!)

      user.remember_me!
      key = Devise.rememberable_options[:key]

      cookies.signed[key] = {
        value: user.class.serialize_into_cookie(user),
        expires: user.remember_expires_at,
        httponly: true,
        secure: request.ssl?,
        same_site: :lax
      }
    end
  end
end
