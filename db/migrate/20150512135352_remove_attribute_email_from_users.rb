class RemoveAttributeEmailFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :email
    add_column :users, :password_autogenerated, :boolean, null: false, default: false
    rename_table :emails, :user_emails
    add_column :user_emails, :is_verified, :boolean, null: false, default: false
  end
end