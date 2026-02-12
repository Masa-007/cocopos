# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    GOOGLE_REAUTH_SESSION_KEY = 'google_reauth_passed_at'
    GOOGLE_REAUTH_FLOW_KEY = 'google_reauth_flow'
    GOOGLE_REAUTH_USER_ID_KEY = 'google_reauth_user_id'
    GOOGLE_REAUTH_WINDOW = 10.minutes

    def update
      self.resource = reload_resource
      prev_unconfirmed_email = fetch_prev_unconfirmed_email(resource)

      return redirect_google_reauth_required if google_user_name_change_without_reauth?

      if update_account(resource)
        clear_google_reauth!
        set_flash_message_for_update(resource, prev_unconfirmed_email)
        bypass_sign_in(resource)
        redirect_to after_update_path_for(resource)
      else
        prepare_update_failure(resource)
        render :edit, status: :unprocessable_entity
      end
    end

    def google_reauth
      session[GOOGLE_REAUTH_FLOW_KEY] = true
      session[GOOGLE_REAUTH_USER_ID_KEY] = current_user.id

      render :google_reauth
    end

    private

    def reload_resource
      resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    end

    def fetch_prev_unconfirmed_email(user)
      return unless user.respond_to?(:unconfirmed_email)

      user.unconfirmed_email
    end

    def redirect_google_reauth_required
      prepare_update_failure(resource)
      flash[:alert] = t('devise.registrations.google_reauth_required')
      redirect_to edit_user_registration_path
    end

    def update_account(user)
      resource_updated = update_resource(user, account_update_params)
      yield user if block_given?
      resource_updated
    end

    def prepare_update_failure(user)
      clean_up_passwords user
      set_minimum_password_length
    end

    def google_user_name_change_without_reauth?
      return false unless google_account?(resource)

      requested_name = account_update_params[:name].to_s
      return false if requested_name.blank?
      return false if requested_name == resource.name

      !recent_google_reauth?
    end

    def google_account?(user)
      user.provider == 'google_oauth2'
    end

    def recent_google_reauth?
      passed_at = session[GOOGLE_REAUTH_SESSION_KEY]
      return false if passed_at.blank?

      Time.zone.at(passed_at.to_i) > GOOGLE_REAUTH_WINDOW.ago
    end

    def clear_google_reauth!
      session.delete(GOOGLE_REAUTH_SESSION_KEY)
      session.delete(GOOGLE_REAUTH_FLOW_KEY)
      session.delete(GOOGLE_REAUTH_USER_ID_KEY)
    end

    def update_resource(user, params)
      return user.update_without_password(params.except(:current_password)) if google_account?(user)

      super
    end
  end
end
