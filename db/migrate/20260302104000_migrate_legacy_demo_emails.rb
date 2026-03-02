# frozen_string_literal: true

class MigrateLegacyDemoEmails < ActiveRecord::Migration[7.1]
  NEW_DEMO_EMAIL = 'cocopos.demo@example.com'
  LEGACY_DEMO_EMAILS = ['cocoposdemo@example.com', 'demo@example.com'].freeze

  def up
    users = legacy_users
    return if users.empty?

    canonical_user = User.find_by(email: NEW_DEMO_EMAIL) || users.first
    canonical_user.update_columns(email: NEW_DEMO_EMAIL, updated_at: Time.current)

    users.where.not(id: canonical_user.id).delete_all
  end

  def down
    # no-op: do not restore legacy demo emails
  end

  private

  def legacy_users
    User.where(email: LEGACY_DEMO_EMAILS).order(:id)
  end
end
