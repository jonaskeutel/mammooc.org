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

    it 'google' do
      expect(User).to receive(:find_for_omniauth).and_return(user)
      get :google
      expect(subject.signed_in?).to be_truthy
    end

    it 'github' do
      expect(User).to receive(:find_for_omniauth).and_return(user)
      get :github
      expect(subject.signed_in?).to be_truthy
    end

    it 'linkedin' do
      expect(User).to receive(:find_for_omniauth).and_return(user)
      get :linkedin
      expect(subject.signed_in?).to be_truthy
    end

    it 'twitter' do
      expect(User).to receive(:find_for_omniauth).and_return(user)
      get :twitter
      expect(subject.signed_in?).to be_truthy
    end

    it 'windows_live' do
      expect(User).to receive(:find_for_omniauth).and_return(user)
      get :windows_live
      expect(subject.signed_in?).to be_truthy
    end

    it 'amazon' do
      expect(User).to receive(:find_for_omniauth).and_return(user)
      get :amazon
      expect(subject.signed_in?).to be_truthy
    end

    context 'easyID' do
      it 'redirects to the same URL with a GET request' do
        post :easy_id, UID: '123'
        expect(response).to redirect_to("#{easy_id_path}?UID=123")
      end

      it 'redirects to the sign in page and shows an error if no UID was provided' do
        get :easy_id
        expect(response).to redirect_to(new_user_session_path)
        expect(flash['error']).to include(I18n.t('users.sign_in_up.easyID.failure'))
      end

      it 'redirects to the sign in page and shows an error if user is not persisted' do
        expect(User).to receive(:find_for_omniauth).and_return(User.new)
        get :easy_id, UID: '123'
        expect(response).to redirect_to(new_user_session_path)
        expect(flash['error']).to include(I18n.t('users.sign_in_up.easyID.failure'))
      end

      it 'signs in the user if everything worked well' do
        expect(User).to receive(:find_for_omniauth).and_return(user)
        get :easy_id, UID: '123'
        expect(response).to redirect_to(dashboard_path)
        expect(flash['success']).to include(I18n.t('users.sign_in_up.easyID.success'))
      end

      it 'uses only the UID without additional characters' do
        expect(User).to receive(:find_for_omniauth).and_return(user)
        uid = SecureRandom.hex(32)
        get :easy_id, UID: "#{uid}%0A"
        expect(controller.send(:easy_id_params)).to eql uid
      end

      it 'redirects the user to the settings page if the user added the connection from there' do
        expect_any_instance_of(ApplicationController).to receive(:ensure_signup_complete).and_return(true)
        sign_in user
        expect(User).to receive(:find_for_omniauth).and_return(user)
        request.env['HTTP_REFERER'] = "#{user_settings_path(user.id)}?subsite=account"
        get :easy_id, UID: '123'
        expect(response).to redirect_to("#{user_settings_path(user.id)}?subsite=account")
        expect(flash['success']).to include(I18n.t('users.sign_in_up.easyID.success'))
      end
    end
  end

  describe 'deauthorize' do
    context 'OmniAuth provider' do
      it 'is not allowed to remove the existing OmniAuth Connection if it is the only one' do
        expect_any_instance_of(ApplicationController).to receive(:ensure_signup_complete).and_return(true)
        sign_in user
        get :deauthorize, provider: identity.omniauth_provider
        expect(flash['error']).to include(I18n.t('users.settings.identity_not_deleted', provider: identity.omniauth_provider.titleize))
      end

      it 'is allowed to remove the OmniAuth connection if the user chose a password' do
        expect_any_instance_of(ApplicationController).to receive(:ensure_signup_complete).and_return(true)
        user.password_autogenerated = false
        user.save!
        sign_in user
        get :deauthorize, provider: identity.omniauth_provider
        expect(flash['success']).to include(I18n.t('users.settings.identity_deleted', provider: identity.omniauth_provider.titleize))
      end

      it 'is allowed to remove the OmniAuth connection if another OmniAuth connection is set up' do
        expect_any_instance_of(ApplicationController).to receive(:ensure_signup_complete).and_return(true)
        FactoryGirl.create(:user_identity, omniauth_provider: 'secondProvider', user: user)
        sign_in user
        get :deauthorize, provider: identity.omniauth_provider
        expect(flash['success']).to include(I18n.t('users.settings.identity_deleted', provider: identity.omniauth_provider.titleize))
      end

      it 'returns an error flash message if the connection was not destroyed' do
        expect_any_instance_of(ApplicationController).to receive(:ensure_signup_complete).and_return(true)
        FactoryGirl.create(:user_identity, omniauth_provider: 'secondProvider', user: user)
        sign_in user
        get :deauthorize, provider: 'not exisiting'
        expect(flash['error']).to include(I18n.t('users.settings.identity_not_deleted', provider: 'not exisiting'.titleize))
      end
    end

    context 'easyID' do
      it 'is not allowed to remove the existing OmniAuth Connection if it is the only one' do
        identity.omniauth_provider = 'easyID'
        identity.save!
        expect_any_instance_of(ApplicationController).to receive(:ensure_signup_complete).and_return(true)
        sign_in user
        get :deauthorize, provider: identity.omniauth_provider
        expect(flash['error']).to include(I18n.t('users.settings.easyID.identity_not_deleted'))
      end

      it 'is allowed to remove the OmniAuth connection if the user chose a password' do
        identity.omniauth_provider = 'easyID'
        identity.save!
        expect_any_instance_of(ApplicationController).to receive(:ensure_signup_complete).and_return(true)
        user.password_autogenerated = false
        user.save!
        sign_in user
        get :deauthorize, provider: identity.omniauth_provider
        expect(flash['success']).to include(I18n.t('users.settings.easyID.identity_deleted'))
      end

      it 'is allowed to remove the OmniAuth connection if another OmniAuth connection is set up' do
        identity.omniauth_provider = 'easyID'
        identity.save!
        expect_any_instance_of(ApplicationController).to receive(:ensure_signup_complete).and_return(true)
        FactoryGirl.create(:user_identity, omniauth_provider: 'secondProvider', user: user)
        sign_in user
        get :deauthorize, provider: identity.omniauth_provider
        expect(flash['success']).to include(I18n.t('users.settings.easyID.identity_deleted'))
      end

      it 'returns an error flash message if the connection was not destroyed' do
        expect_any_instance_of(ApplicationController).to receive(:ensure_signup_complete).and_return(true)
        FactoryGirl.create(:user_identity, omniauth_provider: 'secondProvider', user: user)
        sign_in user
        get :deauthorize, provider: 'easyID'
        expect(flash['error']).to include(I18n.t('users.settings.easyID.identity_not_deleted'))
      end
    end
  end
end
