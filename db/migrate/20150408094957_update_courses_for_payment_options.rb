# -*- encoding : utf-8 -*-
class UpdateCoursesForPaymentOptions < ActiveRecord::Migration
  def change
    add_column(:courses, :has_paid_version, :boolean)
    add_column(:courses, :has_free_version, :boolean)
  end
end
