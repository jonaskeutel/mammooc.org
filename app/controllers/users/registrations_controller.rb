# -*- encoding : utf-8 -*-
require 'devise_helper'

module Users
  class RegistrationsController < Devise::RegistrationsController
    def new
      super
    end

    def create
      flash['error'] ||= []
      full_user_params = sign_up_params
      full_user_params[:profile_image_id] = 'profile_picture_default.png'
      build_resource(full_user_params)
      resource.save

      yield resource if block_given?
      if resource.persisted? && user_params.key?(:terms_and_conditions_confirmation)
        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_flashing_format?
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        session[:resource] = resource
        resource.destroy
        resource.errors.each do |key, value|
          flash['error'] << "#{t('users.sign_in_up.' + key.to_s)} #{value}"
        end
        redirect_to new_user_registration_path
      end

      return if user_params.key?(:terms_and_conditions_confirmation)
      flash['error'] << t('flash.error.sign_up.terms_and_conditions_failure')
    end

    def update
      puts 'blub'
      flash['error'] ||= []

      self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
      prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

      resource_updated = update_resource(resource, account_update_params)
      yield resource if block_given?
      if resource_updated
        if is_flashing_format?
          flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
              :update_needs_confirmation : :updated
          set_flash_message :notice, flash_key
        end
        sign_in resource_name, resource, bypass: true
      else
        resource.errors.each do |key, value|
          flash['error'] << "#{t('users.sign_in_up.' + key.to_s)} #{value}"
        end
        puts 'resource_not_updated'
        clean_up_passwords resource
      end
      redirect_to "/users/#{current_user.id}/settings?subsite=account"

    end


    protected

    def after_sign_up_path_for(resource)
      after_sign_in_path_for(resource)
    end

    def after_update_path_for(resource)
      after_sign_in_path_for(resource)
    end

    private

    def sign_up_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end

    def user_params
      params.permit(:terms_and_conditions_confirmation)
    end

    def add_resource
      @resource = session[:resource]
    end
  end
end
