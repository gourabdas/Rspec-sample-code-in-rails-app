require 'spec_helper'

describe Admins::SessionsController do

  render_views
  
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
  end

    describe 'login' do
  
      it "should be successful" do
        get :new
        response.should be_success
      end
  
      it "should have right content" do
        visit new_admin_session_url(:host => HOST_WITH_PORT, :subdomain => 'admin')
        page.should have_button("Login")
      end
  
      it "should be submit valid authentication for authenticated user" do
          visit new_admin_session_url(:host => HOST_WITH_PORT, :subdomain => 'admin')
          within("#new_admin") do
            fill_in "admin[email]",     :with => Faker::Internet.email
            fill_in "admin[password]",  :with => "test123"
            click_on "Login"
          end
        page.should have_content("Invalid email or password.")
      end
  
      it "should be sign in successfully" do
        admin = Factory(:admin)
        visit new_user_session_url(:host => HOST_WITH_PORT, :subdomain => 'admin')
        within("#new_admin") do
          fill_in "admin[email]",     :with => admin.email
          fill_in "admin[password]",  :with => admin.password
          click_on "Login"
        end
        page.should have_content("Signed in successfully.")
      end
    end
  
  describe "create method" do
    describe "failure" do
      before(:each) do
        @request.host = HOST_WITH_PORT
        @attr = { :email => Faker::Internet.email, :password => "test" }
      end

      it "should render the login page" do
        post :create, :admin => @attr
        response.should render_template('new')
      end

      it "should have an error message" do
        post :create, :user => @attr
        flash[:error].should =~ /Invalid email or password./i
      end
    end

    describe "success" do
      before(:each) do
        @request.host = HOST_WITH_PORT
        @admin = Factory(:admin)
        @attr = { :email => @admin.email, :password => @admin.password }
      end

      it "should have a successful message" do
        post :create, :admin => @attr
        flash[:notice].should =~ /Signed in successfully./i
      end
    end
  end



end
