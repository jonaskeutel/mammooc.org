# -*- encoding : utf-8 -*-
class ChangeIsAdminDefaultToFalse < ActiveRecord::Migration
  def change
    change_column_default :user_groups, :is_admin, false
  end
end
