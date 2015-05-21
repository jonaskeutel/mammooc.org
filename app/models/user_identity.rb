class UserIdentity < ActiveRecord::Base
  belongs_to :user
  validates :provider_user_id, presence: true, uniqueness: {scope: :omniauth_provider}
  validates :omniauth_provider, presence: true

  def self.find_for_omniauth(authentication_info)
    find_or_create_by(provider_user_id: authentication_info.uid, omniauth_provider: authentication_info.provider)
  end
end