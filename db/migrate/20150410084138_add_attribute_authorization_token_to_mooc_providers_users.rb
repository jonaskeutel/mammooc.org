# frozen_string_literal: true

class AddAttributeAuthorizationTokenToMoocProvidersUsers < ActiveRecord::Migration[4.2]
  def change
    add_column(:mooc_providers_users, :authentication_token, :string)
  end
end
