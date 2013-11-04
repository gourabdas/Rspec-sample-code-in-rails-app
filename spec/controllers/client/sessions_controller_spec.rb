require "spec_helper"

describe Client::SessionsController do
  render_views

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "Login" do
    it "should be successful" do
      get :new
      response.should be_success
    end

    it "should be active right tab" do
      visit new_user_session_url(:host => HOST_WITH_PORT, :subdomain => nil)
      find("li.active").should have_content("Sign In")
    end

    it "should have right content" do
      visit new_user_session_url(:host => HOST_WITH_PORT, :subdomain => nil)
      page.should have_content("Login as an Agency")
    end

    it "should be submit valid authentication for authenticated user" do
      visit new_user_session_url(:host => HOST_WITH_PORT, :subdomain => nil)
      within("#new_user") do
        fill_in "user[email]",     :with => Faker::Internet.email
        fill_in "user[password]",  :with => "test123"
        click_on "Login"
      end
      page.should have_content("Invalid email or password.")
    end

    it "should be sign in successfully" do
      Factory(:company)
      user = Factory(:user)
      visit new_user_session_url(:host => HOST_WITH_PORT, :subdomain => nil)
      within("#new_user") do
        fill_in "user[email]",     :with => user.email
        fill_in "user[password]",  :with => user.password
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

      it "should re-render the login page" do
        post :create, :user => @attr
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
        Factory(:company)
        @user = Factory(:user)
        @attr = { :email => @user.email, :password => @user.password }
      end

      it "should have a successful message" do
        post :create, :user => @attr
        flash[:notice].should =~ /Signed in successfully./i
      end
    end
  end
end