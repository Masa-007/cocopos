# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    def update
      self.resource = reload_resource
      prev_unconfirmed_email = fetch_prev_unconfirmed_email(resource)

      resource_updated = update_resource(resource, account_update_params)
      yield resource if block_given?

      if resource_updated
        handle_update_success(resource, prev_unconfirmed_email)
      else
        handle_update_failure(resource)
      end
    end

    private

    def reload_resource
      resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    end

    def fetch_prev_unconfirmed_email(resource)
      return unless resource.respond_to?(:unconfirmed_email)

      resource.unconfirmed_email
    end

    def handle_update_success(resource, prev_unconfirmed_email)
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      bypass_sign_in_if_password_changed(resource)
      respond_with resource, location: after_update_path_for(resource)
    end

    def bypass_sign_in_if_password_changed(resource)
      return unless sign_in_after_change_password?
      return if account_update_params[:password].blank?

      sign_in(resource_name, resource, bypass: true)
    end

    def handle_update_failure(resource)
      clean_up_passwords resource
      set_minimum_password_length
      flash.now[:alert] = t('devise.registrations.update_failed')
      respond_with resource
    end
  end
end
