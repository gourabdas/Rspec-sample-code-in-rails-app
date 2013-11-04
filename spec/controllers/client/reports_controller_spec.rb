require 'spec_helper'

describe Client::ReportsController do
  render_views
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @company = Factory(:company)
    visit new_user_session_url(:host => HOST_WITH_PORT, :subdomain => nil)
    user = Factory(:user, :is_admin => true)
    within("#new_user") do
      fill_in "user[email]",     :with => user.email
      fill_in "user[password]",  :with => user.password
      click_on "Login"
    end
    sign_in :user, user
  end
end