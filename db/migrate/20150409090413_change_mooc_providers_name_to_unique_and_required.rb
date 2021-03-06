# frozen_string_literal: true

class ChangeMoocProvidersNameToUniqueAndRequired < ActiveRecord::Migration[4.2]
  def change
    add_index :mooc_providers, :name, unique: true
    change_column(:mooc_providers, :name, :string, null: false)
  end
end
