# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'users/edit', type: :view do
  let!(:user) { assign(:user, FactoryGirl.create(:fullUser)) }

  it 'renders the edit user form' do
    render
    assert_select 'form[action=?][method=?]', user_path(user), 'post' do
      assert_select 'input#user_first_name[name=?]', 'user[first_name]'
      assert_select 'input#user_last_name[name=?]', 'user[last_name]'
      assert_select 'textarea#user_about_me[name=?]', 'user[about_me]'
    end
  end
end
