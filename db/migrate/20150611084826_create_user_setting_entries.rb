# frozen_string_literal: true

class CreateUserSettingEntries < ActiveRecord::Migration[4.2]
  def change
    create_table :user_setting_entries, id: :uuid do |t|
      t.string :key
      t.string :value
      t.references :user_setting, type: 'uuid', index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
