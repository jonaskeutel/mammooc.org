# frozen_string_literal: true

class CreateGroupInvitations < ActiveRecord::Migration[4.2]
  def change
    create_table :group_invitations do |t|
      t.references :group, type: 'uuid', index: true, null: false
      t.string :token, null: false
      t.datetime :expiry_date, null: false

      t.timestamps null: false
    end
    add_foreign_key :group_invitations, :groups
  end
end
