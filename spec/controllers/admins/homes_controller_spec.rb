require 'spec_helper'

describe Admins::HomesController do
  render_views

  before(:each) do
    @request.host = HOST_WITH_PORT
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    visit new_admin_session_url(:subdomain => 'admin')
    @admin = Factory(:admin)
    within("#new_admin") do
      fill_in "admin[email]",     :with => @admin.email
      fill_in "admin_password",  :with => @admin.password
      click_on "Login"
    end
    sign_in :admin, @admin
    @company = Factory(:company)
  end

  describe "page" do
    it "should be perform change password", :js => true do
      visit change_password_url(:subdomain => "admin")
      within('#formID') do
        fill_in 'admin[password]', :with => '123456'
        fill_in 'admin[password_confirmation]', :with => '123456'
        fill_in 'admin[current_password]', :with => @admin.password
        click_on 'Change Password'
      end
      page.should have_content('Password was changed successfully.')      
    end
  end


  describe 'change_password' do
    before(:each) do
      @password_attr = {:password => '123456', :current_password => @admin.password, :password_confirmation => '123456'}
    end
    it "should get change password page" do
      get :change_password
      response.should be_success
    end
  
    it "should update the password" do
      put :password_changed, :admin => @password_attr      
      response.should redirect_to(root_path)
    end
  end

  describe 'switch_user' do
    it "should switch the valid user url with token and subdomain" do
      get :switch_user, :token => 'abc123',:subdomain => @company.subdomain
      response.should redirect_to(valid_user_url(:token => 'abc123', :subdomain => @company.subdomain))
    end
  end

  describe 'changed_status' do
    it "should change status of the company" do
      xhr :post, :changed_status, :id => @company
      response.status.should == 201
    end
  end

end
