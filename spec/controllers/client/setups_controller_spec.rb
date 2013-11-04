require "spec_helper"

describe Client::SetupsController do
  render_views

  describe "Page" do
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

    describe "index" do
      it "should be active right tab" do
        visit root_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        find("li.active").should have_content("Setup")
        find("ul.nav-tabs > li.active").should have_content("Company")
      end

      it "should have right link" do
        visit root_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        page.should have_link("Edit Company Profile")
      end

      it "should have right content" do
        visit root_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        page.should have_content(subject.current_user.company.name)
      end
    end

    describe "company_edit" do
      it "should be active right tab" do
        visit client_company_setup_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        find("li.active").should have_content("Setup")
        find("ul.nav-tabs > li.active").should have_content("Company")
      end

      it "should be perform validation on form submit", :js => true do
        Factory(:country)
        visit client_company_setup_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        within(".bs-docs") do
          fill_in "company[name]",        :with => @company.name
          fill_in "company[subdomain]",   :with => nil
          fill_in "company[address1]",    :with => Faker::Address.street_name
          fill_in "company[zip]",         :with => Faker::Address.zip_code
          select "MM-DD-YYYY",            :with => "company[formatted_date]"
          select "India",                 :from => "company[country_id]"
          click_on "Save"
        end
        find("div.company_subdomainformError").should have_content("* This field is required")
      end

      it "should be submit form successfully", :js => true do
        Factory(:country)
        Factory(:industry_type)
        visit client_company_setup_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        within(".bs-docs") do
          fill_in "company[name]",        :with => @company.name
          fill_in "company[subdomain]",   :with => @company.subdomain
          fill_in "company[address1]",    :with => Faker::Address.street_name
          fill_in "company[zip]",         :with => Faker::Address.zip_code
          select "MM-DD-YYYY",            :with => "company[formatted_date]"
          select "India",                 :from => "company[country_id]"
          select "Automotive",            :from => "company[industry_type_id]"
          click_on "Save"
        end
        page.should have_content("Company details have been updated successfully.")
      end
    end

    describe "company_user" do
      before(:each) do
        30.times do
          Factory(:user, :first_name => Factory.next(:first_name), :last_name => Factory.next(:last_name), :email => Factory.next(:email))
        end
      end

      it "should be active right tab" do
        visit client_company_user_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        find("ul.nav-tabs > li.active").should have_content("User")
      end

      it "should have right link" do
        visit client_company_user_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        page.should have_selector('i.icon-plus', :content => "New User")
      end

      it "should paginate users", :js => true do
        visit client_company_user_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        page.should have_selector('div.dataTables_paginate')
        page.should have_selector('li.disabled > a', :content => "← Previous")
        #page.should have_selector('a', :content => "2")
        #page.should have_selector('a', :content => "Next → ")
      end

      it "should open action dropdown", :js => true do
        visit client_company_user_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        find('a.dropdown-toggle', :text => "Actions").click
        page.has_css?('ul', :class => 'dropdown-menu', :visible => true).should be_true
      end
    end

    describe "new_user" do
      it "should be perform validation on form submit", :js => true do
        Factory(:country)
        visit client_company_new_user_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        within("#formID") do
          fill_in "user[first_name]",             :with => Faker::Name.first_name
          fill_in "user[last_name]",              :with => Faker::Name.last_name
          fill_in "user[address2]",               :with => Faker::Address.street_name
          check("select-all-brands")
          fill_in "user[contact_no]",             :with => Faker::PhoneNumber.phone_number
          select "India",                         :from => "user[country_id]"
          fill_in "user[zip]",                    :with => Faker::Address.zip_code
          fill_in "user[email]",                  :with => nil
          fill_in "user[password]",               :with => "123456"
          fill_in "user[password_confirmation]",  :with => "123456"
          check("select-all-markets")
          click_on "Save"
        end
        find("div.user_emailformError").should have_content("* This field is required")
      end

      it "should be submit form successfully", :js => true do
        Factory(:country)
        visit client_company_new_user_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        within("#formID") do
          fill_in "user[first_name]",             :with => Faker::Name.first_name
          fill_in "user[last_name]",              :with => Faker::Name.last_name
          fill_in "user[address1]",               :with => Faker::Address.street_name
          check("select-all-brands")
          fill_in "user[contact_no]",             :with => Faker::PhoneNumber.phone_number
          select "India",                         :from => "user[country_id]"
          fill_in "user[zip]",                    :with => Faker::Address.zip_code
          fill_in "user[email]",                  :with => Faker::Internet.email
          fill_in "user[password]",               :with => "123456"
          fill_in "user[password_confirmation]",  :with => "123456"
          check("select-all-markets")
          click_on "Save"
        end
        page.should have_content("User have been created successfully.")
      end
    end

    describe "company_user_edit" do
      it "should be perform validation on form submit", :js => true do
        Factory(:country)
        visit client_company_user_edit_url(:id => subject.current_user.id, :host => HOST_WITH_PORT, :subdomain => "testing")
        within("#formID") do
          fill_in "user[first_name]",             :with => Faker::Name.first_name
          fill_in "user[last_name]",              :with => Faker::Name.last_name
          fill_in "user[address1]",               :with => Faker::Address.street_name
          check("select-all-brands")
          fill_in "user[email]",                  :with => nil
          fill_in "user[contact_no]",             :with => Faker::PhoneNumber.phone_number
          fill_in "user[zip]",                    :with => Faker::Address.zip_code
          select "India",                         :from => "user[country_id]"
          check("select-all-markets")
          click_on "Save"
        end
        find("div.user_emailformError").should have_content("* This field is required")
      end

      it "should be submit form successfully", :js => true do
        Factory(:country)
        visit client_company_user_edit_url(:id => subject.current_user.id, :host => HOST_WITH_PORT, :subdomain => "testing")
        within("#formID") do
          fill_in "user[first_name]",             :with => Faker::Name.first_name
          fill_in "user[last_name]",              :with => Faker::Name.last_name
          fill_in "user[address1]",               :with => Faker::Address.street_name
          check("select-all-brands")
          fill_in "user[email]",                  :with => subject.current_user.email
          fill_in "user[contact_no]",             :with => Faker::PhoneNumber.phone_number
          fill_in "user[zip]",                    :with => Faker::Address.zip_code
          select "India",                         :from => "user[country_id]"
          check("select-all-markets")
          click_on "Save"
        end
        page.should have_content("User have been updated successfully.")
      end
    end
  end

  describe "Action" do
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @company = Factory(:company)
      user = Factory(:user, :is_admin => true)
      sign_in :user, user
    end

    describe "index" do
      it "should get index" do
        get :index
        response.should be_success
      end
    end

    describe "company_edit" do
      it "should get index" do
        get :company_edit
        response.should be_success
      end
    end

    describe "company_update" do
      describe "failure" do
        before(:each) do
          @attr = { :name => nil }
        end

        it "should be re-render to the company edit page" do
          post :company_update, :company => @attr
          response.should redirect_to(client_company_setup_path)
        end

        it "should have an error message" do
          post :company_update
          flash[:error].should =~ /ERROR: Please submit proper data./i
        end
      end

      describe "success" do
        before(:each) do
          @attr = { :name => Faker::Company.name, :subdomain => @company.subdomain, :address1 => Faker::Address.street_name, :zip => Faker::Address.zip_code }
        end

        it "should change the company's attributes" do
          post :company_update, :company => @attr
          @company.reload
          @company.name.should  == @attr[:name]
          @company.address1.should  == @attr[:address1]
          @company.zip.should  == @attr[:zip]
        end

        it "should redirect to the home page" do
          post :company_update, :company => @attr
          response.should redirect_to(root_path)
        end

        it "should have a successful message" do
          post :company_update, :company => @attr
          flash[:notice].should =~ /Company details have been updated successfully./i
        end
      end
    end

    describe "company_user" do
      it "should be successful" do
        get :company_user
        response.should be_success
      end
    end

    describe "new_user" do
      it "should be successful" do
        get :new_user
        response.should be_success
      end
    end

    describe "create_user" do
      describe "failure" do
        before(:each) do
          @attr = { :first_name => nil }
        end

        it "should be re-render to the company edit page" do
          post :create_user, :user => @attr
          response.should redirect_to(client_company_new_user_path)
        end

        it "should have an error message" do
          post :create_user
          flash[:error].should =~ /ERROR: Please submit proper data./i
        end
      end

      describe "success" do
        before(:each) do
          @attr = { :first_name => Faker::Name.first_name, :last_name => Faker::Name.last_name, :address1 => Faker::Address.street_name, :contact_no => Faker::PhoneNumber.phone_number, :zip => Faker::Address.zip_code, :email => Faker::Internet.email, :password => "123456", :password_confirmation => "123456" }
        end

        it "should create a user record" do
          lambda do
            post :create_user, :user => @attr
          end.should change(User, :count).by(1)
        end

        it "should redirect to the user list page" do
          post :create_user, :user => @attr
          response.should redirect_to(client_company_user_path)
        end

        it "should have a successful message" do
          post :create_user, :user => @attr
          flash[:notice].should =~ /User have been created successfully./i
        end
      end
    end

    describe "company_user_edit" do
      it "should be successful" do
        get :company_user_edit, :id => subject.current_user.id
        response.should be_success
      end
    end

    describe "company_user_update" do
      describe "failure" do
        before(:each) do
          @attr = { :first_name => nil }
        end

        it "should be re-render to the company edit page" do
          post :company_user_update, :id => subject.current_user.id, :user => @attr
          response.should render_template('company_user_edit')
        end

        it "should have an error message" do
          post :company_user_update, :id => subject.current_user.id
          flash[:error].should =~ /ERROR: Please submit proper data./i
        end
      end

      describe "success" do
        before(:each) do
          @attr = { :first_name => Faker::Name.first_name, :last_name => Faker::Name.last_name, :address1 => Faker::Address.street_name, :contact_no => Faker::PhoneNumber.phone_number, :zip => Faker::Address.zip_code }
        end

        it "should change the user's attributes" do
          post :company_user_update, :id => subject.current_user.id, :user => @attr
          subject.current_user.reload
          subject.current_user.first_name.should == @attr[:first_name]
          subject.current_user.last_name.should == @attr[:last_name]
          subject.current_user.address1.should == @attr[:address1]
          subject.current_user.contact_no.should == @attr[:contact_no]
          subject.current_user.zip.should == @attr[:zip]
        end

        it "should redirect to the user list page" do
          post :company_user_update, :id => subject.current_user.id, :user => @attr
          response.should redirect_to(client_company_user_path)
        end

        it "should have a successful message" do
          post :company_user_update, :id => subject.current_user.id, :user => @attr
          flash[:notice].should =~ /User have been updated successfully./i
        end
      end
    end

    describe "company_user_delete" do
      it "should destroy the user" do
        delete :company_user_delete, :id => subject.current_user.id
        subject.current_user.reload
        subject.current_user.is_blocked.should == true
      end

      it "should redirect to the users page" do
        delete :company_user_delete, :id => subject.current_user.id
        response.should redirect_to(client_company_user_path)
      end
    end
  end
end