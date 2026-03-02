# frozen_string_literal: true

class EnsureDemoAccountExists < ActiveRecord::Migration[7.1]
  DEMO_EMAIL = 'cocopos.demo@example.com'
  DEMO_NAME = 'お試しさん'
  DEMO_PASSWORD = 'password'

  def up
    User.reset_column_information

    user = User.find_or_initialize_by(email: DEMO_EMAIL)
    user.name = DEMO_NAME
    user.password = DEMO_PASSWORD
    user.password_confirmation = DEMO_PASSWORD
    user.save!
  end

  def down
    # no-op: keep demo account for operational consistency
  end
end
