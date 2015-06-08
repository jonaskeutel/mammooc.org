# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  include Devise::TestHelpers
  include Warden::Test::Helpers

  let(:user) { FactoryGirl.create(:OmniAuthUser) }
  let(:identity) { UserIdentity.find_by(user: user) }

  before(:each) do
    request.env['devise.mapping'] = Devise.mappings[:user]
    Warden.test_mode!
    OmniAuth.config.test_mode = true
  end

  describe 'OmniAuth providers' do
    it 'facebook' do
      expect(User).to receive(:find_for_omniauth).and_return(user)
      get :facebook
      expect(subject.signed_in?).to be_truthy
    end
  end

  describe 'deauthorize' do
    before(:each) do
      expect_any_instance_of(ApplicationController).to receive(:ensure_signup_complete).and_return(true)
      sign_in user
    end

    it 'is not allowed to remove the existing OmniAuth Connection if it is the only one' do
      get :deauthorize, provider: identity.omniauth_provider
      expect(flash['error']).to include(I18n.t('users.settings.identity_not_deleted', provider: identity.omniauth_provider.titleize))
    end

    it 'is allowed to remove the OmniAuth connection if the user chose a password' do
      user.password_autogenerated = false
      user.save!
      get :deauthorize, provider: identity.omniauth_provider
      expect(flash['success']).to include(I18n.t('users.settings.identity_deleted', provider: identity.omniauth_provider.titleize))
    end

    it 'is allowed to remove the OmniAuth connection if another OmniAuth connection is set up' do
      FactoryGirl.create(:user_identity, omniauth_provider: 'secondProvider', user: user)
      get :deauthorize, provider: identity.omniauth_provider
      expect(flash['success']).to include(I18n.t('users.settings.identity_deleted', provider: identity.omniauth_provider.titleize))
    end

    it 'returns an error flash message if the connection was not destroyed' do
      FactoryGirl.create(:user_identity, omniauth_provider: 'secondProvider', user: user)
      get :deauthorize, provider: 'not exisiting'
      expect(flash['error']).to include(I18n.t('users.settings.identity_not_deleted', provider: 'not exisiting'.titleize))
    end
  end
end
