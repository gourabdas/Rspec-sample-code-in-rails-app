require "spec_helper"

describe PagesController do
  render_views
  
  describe "index method" do
    it "should be successful" do
      get :index
      response.should be_success
    end

    it "should be active right tab" do
      visit root_url(:host => HOST_WITH_PORT, :subdomain => nil)
      find("li.active").should have_content("Home")
    end
  end

  describe "about method" do
    it "should be successful" do
      get :about
      response.should be_success
    end

    it "should be active right tab" do
      visit about_rightspend_url(:host => HOST_WITH_PORT, :subdomain => nil)
      find("li.active").should have_content("About")
    end
  end

  describe "contact method" do
    it "should be successful" do
      get :contact
      response.should be_success
    end

    it "should be active right tab" do
      visit contact_us_url(:host => HOST_WITH_PORT, :subdomain => nil)
      find("li.active").should have_content("Contact Us")
    end

    it "should not be visible state dropdown normally", :js => true do
      visit contact_us_url(:host => HOST_WITH_PORT, :subdomain => nil)
      within("#formID") do
        page.has_css?("select", :class => "user-state-drop-down", :visible => false).should be_true
      end
    end

    it "should not be visible state dropdown if country selected other than United States", :js => true do
      Factory(:country)
      visit contact_us_url(:host => HOST_WITH_PORT, :subdomain => nil)
      within("#formID") do
        select "India", :from => "contact_us[country_id]"
        page.has_css?("select", :class => "user-state-drop-down", :visible => false).should be_true
      end
    end

    it "should be visible state dropdown if country selected is United States", :js => true do
      FactoryGirl.create(:country, :id => "506aea056e01ed4c1a0000d8", :iso => "US", :name => "UNITED STATES", :printable_name => "United States", :iso3 => "USA", :numcode => "840", :symbol => "$", :currency => "USD")
      visit contact_us_url(:host => HOST_WITH_PORT, :subdomain => nil)
      within("#formID") do
        select "United States", :from => "contact_us[country_id]"
        page.has_css?("select", :class => "user-state-drop-down", :visible => true).should be_true
      end
    end

    it "should be perform validation on form submit", :js => true do
      Factory(:country)
      visit contact_us_url(:host => HOST_WITH_PORT, :subdomain => nil)
      within("#formID") do
        fill_in "contact_us[company_name]", :with => Faker::Company.name
        fill_in "contact_us[first_name]",   :with => Faker::Name.first_name
        fill_in "contact_us[last_name]",    :with => Faker::Name.last_name
        fill_in "contact_us[address1]",     :with => Faker::Address.street_name
        fill_in "contact_us[city]",         :with => Faker::Address.city
        select "India",                     :from => "contact_us[country_id]"
        fill_in "contact_us[contact_no]",   :with => Faker::PhoneNumber.phone_number
        fill_in "contact_us[zip]",          :with => Faker::Address.zip_code
        click_on "submit"
      end
      find("div.contact_us_emailformError").should have_content("* This field is required")
    end

    it "should be submit form successfully", :js => true do
      Factory(:country)
      visit contact_us_url(:host => HOST_WITH_PORT, :subdomain => nil)
      within("#formID") do
        fill_in "contact_us[company_name]", :with => Faker::Company.name
        fill_in "contact_us[first_name]",   :with => Faker::Name.first_name
        fill_in "contact_us[last_name]",    :with => Faker::Name.last_name
        fill_in "contact_us[address1]",     :with => Faker::Address.street_name
        fill_in "contact_us[city]",         :with => Faker::Address.city
        select "India",                     :from => "contact_us[country_id]"
        fill_in "contact_us[contact_no]",   :with => Faker::PhoneNumber.phone_number
        fill_in "contact_us[email]",        :with => Faker::Internet.email
        fill_in "contact_us[zip]",          :with => Faker::Address.zip_code
        click_on "submit"
      end
      page.should have_content("Successfully sent your details to RightSpend's product administrator. RightSpend's product administrator will create your account shortly and you will get a confirmation email from RightSpend in your registered email address.")
    end
  end

  describe "create_user method" do
    describe "failure" do
      before(:each) do
        @request.host = HOST_WITH_PORT
        @attr = { :company_name => Faker::Company.name }
      end

      it "should re-render the contact us page" do
        post :create_user, :contact_us => @attr
        response.should render_template('contact')
      end

      it "should have an error message" do
        post :create_user
        flash[:error].should =~ /ERROR: Please submit proper data./i
      end
    end

    describe "success" do
      before(:each) do
        @request.host = HOST_WITH_PORT
        country = Factory(:country)
        @attr = {
          :company_name => Faker::Company.name,
          :first_name => Faker::Name.first_name,
          :last_name => Faker::Name.last_name,
          :address1 => Faker::Address.street_name,
          :city => Faker::Address.city,
          :country_id => country.id,
          :contact_no => Faker::PhoneNumber.phone_number,
          :email => Faker::Internet.email,
          :zip => Faker::Address.zip_code
        }
      end

      it "should create a contact_us record" do
        lambda do
          post :create_user, :contact_us => @attr
        end.should change(ContactUs, :count).by(1)
      end

      it "should redirect to the home page" do
        post :create_user, :contact_us => @attr
        response.should redirect_to(root_path)
      end

      it "should have a successful message" do
        post :create_user, :contact_us => @attr
        flash[:notice].should =~ /Successfully sent your details to RightSpend's product administrator. RightSpend's product administrator will create your account shortly and you will get a confirmation email from RightSpend in your registered email address./i
      end

      it "should deliver the contact us email" do
        post :create_user, :contact_us => @attr
        mail = ActionMailer::Base.deliveries.last
        mail.to.should == ["diganta@circarconsulting.com"]
        mail.subject.should == "Request to create a new client account"
        mail.html_part.body.should match /#{@attr[:email]}/
      end
    end
  end
end