require 'rails_helper'

RSpec.describe "home/index.html.slim", :type => :view do
  it "renders caption" do
    render
    expect(rendered).to match(t('welcome_heading'))
  end
end
