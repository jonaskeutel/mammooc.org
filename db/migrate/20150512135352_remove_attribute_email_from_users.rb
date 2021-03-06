# frozen_string_literal: true

class RemoveAttributeEmailFromUsers < ActiveRecord::Migration[4.2]
  def change
    change_table(:users, bulk: true) do |t|
      t.remove :email
      t.boolean :password_autogenerated, null: false, default: false
    end

    rename_table :emails, :user_emails
    add_column :user_emails, :is_verified, :boolean, null: false, default: false
  end
end
