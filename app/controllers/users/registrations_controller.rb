# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    prev_unconfirmed_email =
      resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?

    if resource_updated
      set_flash_message_for_update(resource, prev_unconfirmed_email)

      if sign_in_after_change_password? && account_update_params[:password].present?
        sign_in(resource_name, resource, bypass: true)
      end

      respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      flash.now[:alert] = t("devise.registrations.update_failed")
      respond_with resource
    end
  end
end
