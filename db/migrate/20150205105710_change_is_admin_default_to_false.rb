# frozen_string_literal: true

class ChangeIsAdminDefaultToFalse < ActiveRecord::Migration[4.2]
  def change
    change_column_default :user_groups, :is_admin, false
  end
end
