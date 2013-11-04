require 'spec_helper'

describe Client::VendorsController do
  render_views

  describe "page" do
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
      Factory(:agency_type)
      Factory(:discipline)
      Factory(:market)
      Factory(:company_discipline)
      Factory(:brand)
      Factory(:department)
      Factory(:job_title)
      Factory(:benchmark_salary)
      Factory(:brand_vendor)
      @vendor = Factory(:vendor)
    end

    describe "new_vendor" do
      it "should be perform form validation on form submit", :js => true do
        Factory(:country)
        visit new_client_vendor_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        page.should have_button('Add New')
        within('#vendor-form-id') do
          fill_in "vendor[name]", :with => nil
          select "Agency", :from => 'vendor[agency_type_id]'
          select "Advertising",:from =>"vendor[discipline_id]"
          fill_in "vendor[contact_person]", :with => Faker::Name.name
          fill_in "vendor[title]", :with => "test"
          fill_in "vendor[email]", :with => Faker::Internet.email
          fill_in "vendor[contact_no]", :with => Faker::PhoneNumber.phone_number
          fill_in "vendor[address1]", :with => Faker::Address.street_address
          fill_in "vendor[address2]", :with => nil
          fill_in "vendor[city]", :with => Faker::Address.city
          select "India", :from => "vendor[country_id]"
          fill_in "vendor[zipcode]", :with => Faker::Address.zip_code
          select "India", :from => "vendor[market_id]"
          check('select-all-brands')
          click_on 'Save'
        end
        page.find('div.vendor_nameformError').should have_content('* This field is required')
      end

      it "should be submit form successfully", :js => true do
        Factory(:country)
        visit new_client_vendor_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        within('#vendor-form-id') do
          fill_in "vendor[name]", :with => Faker::Lorem.word
          select "Agency", :from => 'vendor[agency_type_id]'
          select "Advertising",:from =>"vendor[discipline_id]"
          fill_in "vendor[contact_person]", :with => Faker::Name.name
          fill_in "vendor[title]", :with => "test"
          fill_in "vendor[email]", :with => Faker::Internet.email
          fill_in "vendor[contact_no]", :with => Faker::PhoneNumber.phone_number
          fill_in "vendor[address1]", :with => Faker::Address.street_address
          fill_in "vendor[address2]", :with => nil
          fill_in "vendor[city]", :with => Faker::Address.city
          select "India", :from => "vendor[country_id]"
          fill_in "vendor[zipcode]", :with => Faker::Address.zip_code
          select "India", :from => "vendor[market_id]"
          check('select-all-brands')
          click_on 'Save'
        end
        page.should have_content("Successfully created.")
      end

      it "should be submit the form and goes to the setup contract metrics page successfully", :js=> true do
        Factory(:country)
        visit new_client_vendor_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        within('#vendor-form-id') do
          fill_in "vendor[name]", :with => Faker::Lorem.word
          select "Agency", :from => 'vendor[agency_type_id]'
          select "Advertising",:from =>"vendor[discipline_id]"
          fill_in "vendor[contact_person]", :with => Faker::Name.name
          fill_in "vendor[title]", :with => "test"
          fill_in "vendor[email]", :with => Faker::Internet.email
          fill_in "vendor[contact_no]", :with => Faker::PhoneNumber.phone_number
          fill_in "vendor[address1]", :with => Faker::Address.street_address
          fill_in "vendor[address2]", :with => nil
          fill_in "vendor[city]", :with => Faker::Address.city
          select "India", :from => "vendor[country_id]"
          fill_in "vendor[zipcode]", :with => Faker::Address.zip_code
          select "India", :from => "vendor[market_id]"
          check('select-all-brands')
          click_on 'Save & Setup Contract Metrics'
        end
        page.should have_content("Successfully created.")
      end

      it "should check the add new button functionality for creating a new brand from vendor new page", :js => true do
        Factory(:country)
        visit new_client_vendor_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        within('#vendor-form-id') do
          find_button('Add New').click
        end
        find('#formID').should have_button('Save')
        within("#formID") do
          select 'Others', :from => 'brand[business_unit]'
          fill_in 'other_business_unit', :with => "test"
          select "Others", :from => "brand[category]"
          fill_in 'other_category', :with => "test"
          fill_in "brand_name", :with => "testing"
          select "Launch", :from => "brand[lifecycle]"
          fill_in "brand[brand_manager]", :with => "test"
          fill_in "brand[title]", :with => "test"
          fill_in "brand[email]", :with => Faker::Internet.email
          fill_in "brand[contact_no]", :with => Faker::PhoneNumber.phone_number
          click_on "Save"
        end
        page.find('#vendor-form-id').should have_button('Save & Setup Contract Metrics')
      end

      it "should check the cancel functionality" , :js => true do
        visit new_client_vendor_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        find_link('Cancel').click
        page.has_css?("a", :text => "New Vendor", :visible => true).should be_true
      end

      it "should be visible state dropdown if country selected is United States", :js => true do
        FactoryGirl.create(:country, :id => "506aea056e01ed4c1a0000d8", :iso => "US", :name => "UNITED STATES", :printable_name => "United States", :iso3 => "USA", :numcode => "840", :symbol => "$", :currency => "USD")
        visit new_client_vendor_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        within("#vendor-form-id") do
          select "United States", :from => "vendor[country_id]"
          page.has_css?('select',:id => 'vendor-state-drop-down',:visible => true).should be_true
        end
      end

      it "should not be visible state dropdown if the country is selected other than United States", :js => true do
        Factory(:country)
        visit new_client_vendor_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        within("#vendor-form-id") do
          select "India", :from => "vendor[country_id]"
          page.has_css?('select',:id => 'vendor-state-drop-down',:visible => false).should be_true
        end
      end
    end

    describe "vendor_edit" do
      it "should be submit form successfully", :js => true do
        Factory(:country)
        visit edit_client_vendor_url(:host => HOST_WITH_PORT, :subdomain => "testing", :id => @vendor)
        within('#formID') do
          fill_in "vendor[name]", :with => Faker::Lorem.word
          select "Agency", :from => 'vendor[agency_type_id]'
          select "Advertising",:from =>"vendor[discipline_id]"
          fill_in "vendor[contact_person]", :with => Faker::Name.name
          fill_in "vendor[title]", :with => "test"
          fill_in "vendor[email]", :with => Faker::Internet.email
          fill_in "vendor[contact_no]", :with => Faker::PhoneNumber.phone_number
          fill_in "vendor[address1]", :with => Faker::Address.street_address
          fill_in "vendor[address2]", :with => nil
          fill_in "vendor[city]", :with => Faker::Address.city
          select "India", :from => "vendor[country_id]"
          fill_in "vendor[zipcode]", :with => Faker::Address.zip_code
          select "India", :from => "vendor[market_id]"
          check('select-all-brands')
          click_on 'Save'
        end
        page.should have_content("Successfully updated.")
      end

      it "should be perform form validation on form submit", :js => true do
        Factory(:country)
        visit edit_client_vendor_url(:host => HOST_WITH_PORT, :subdomain => "testing", :id => @vendor)
        within('#formID') do
          fill_in "vendor[name]", :with => nil
          select "Agency", :from => 'vendor[agency_type_id]'
          select "Advertising",:from =>"vendor[discipline_id]"
          fill_in "vendor[contact_person]", :with => Faker::Name.name
          fill_in "vendor[title]", :with => "test"
          fill_in "vendor[email]", :with => Faker::Internet.email
          fill_in "vendor[contact_no]", :with => Faker::PhoneNumber.phone_number
          fill_in "vendor[address1]", :with => Faker::Address.street_address
          fill_in "vendor[address2]", :with => nil
          fill_in "vendor[city]", :with => Faker::Address.city
          select "India", :from => "vendor[country_id]"
          fill_in "vendor[zipcode]", :with => Faker::Address.zip_code
          select "India", :from => "vendor[market_id]"
          check('select-all-brands')
          click_on 'Save'
        end
        page.find('div.vendor_nameformError').should have_content('* This field is required')
      end

      it "should be disabled the country and Benchmark Makrket field on vendor edit page", :js => true do
        visit edit_client_vendor_url(:host => HOST_WITH_PORT, :subdomain => "testing", :id => @vendor)
        page.has_css?('select#vendor-country-drop-down[disabled]','select#vendor-market-drop-down[disabled]').should be_true
      end
    end
  end

  describe "Action" do
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @company = Factory(:company)
      user = Factory(:user, :is_admin => true)
      sign_in :user, user
      Factory(:agency_type)
      Factory(:discipline)
      Factory(:market)
      Factory(:country)
      Factory(:company_discipline)
      @plan = Factory(:plan)
      @brand = Factory(:brand)
      Factory(:department)
      Factory(:job_title)
      Factory(:benchmark_salary)
      Factory(:brand_vendor)
      @vendor = Factory(:vendor)
    end
  
    describe "index" do
      it "should get index" do
        get :index
        response.should be_success
      end
    end
  
    describe "vendor_new" do
      it "should get new" do
        get :new
        response.should be_success
      end
    end
  
    describe "create_vendor" do
      describe "failure" do
        before(:each) do
          @attr = { :name => nil }
        end

        it "should be render to the vendor new page" do
          post :create, :vendor => @attr
          response.should render_template('new')
        end
      end

      describe "success" do
        before(:each) do
          @attr = { :name => Faker::Lorem.word, :address1 => Faker::Address.secondary_address, :address2 => nil, :agency_portal => false, :agency_type_id => '506aea066e01ed4c1a000130',:city => Faker::Address.city, :contact_no => Faker::PhoneNumber.phone_number,:contact_person => Faker::Name.name, :country_id => '506aea046e01ed4c1a00005e', :email => Faker::Internet.email, :market_id => '506aead66e01ed4c5700000a', :market_name => 'India', :state_id => nil, :title => 'Business', :zipcode=> Faker::Address.zip_code, :discipline_id => '506aea066e01ed4c1a000131', :brand_ids => @brand }
        end

        it "should create a vendor " do
          lambda do
            post :create, :vendor => @attr
          end.should change(Vendor, :count).by(1)
        end

        it "should redirect to the vendor list page" do
          post :create, :vendor => @attr
          response.should redirect_to(client_vendors_path)
        end

        it "should have a successful message" do
          post :create, :vendor => @attr
          flash[:notice].should =~ /Successfully created./i
        end
      end
    end
  
    describe "company_vendor_edit" do
      it "should be successful" do
        get :edit, :id => @vendor
        response.should be_success
      end
    end

    describe "company_vendor_update" do
      describe "failure" do
        before(:each) do
          @attr = { :name => nil }
        end

        it "should be re-render to the vendor edit page" do
          put :update, :vendor => @attr, :id => @vendor
          response.should render_template('edit')
        end
      end

      describe "success" do
        before(:each) do
          @attr = { :name => Faker::Lorem.word, :address1 => Faker::Address.secondary_address, :address2 => nil, :agency_portal => false, :agency_type_id => '506aea066e01ed4c1a000130', :city => Faker::Address.city, :contact_no => Faker::PhoneNumber.phone_number, :contact_person => Faker::Name.name, :country_id => '506aea046e01ed4c1a00005e', :email => Faker::Internet.email, :market_id => '506aead66e01ed4c5700000a', :state_id => nil, :title => 'Business', :zipcode=> Faker::Address.zip_code, :discipline_id => '506aea066e01ed4c1a000131' }
        end

        it "should change the vendor's attributes" do
          put :update, :id => @vendor, :vendor => @attr
          @vendor.reload
          @vendor.name.should == @attr[:name]
          @vendor.address1.should == @attr[:address1]
          @vendor.address2 .should == @attr[:address2 ]
          @vendor.agency_portal.should == @attr[:agency_portal]
          @vendor.agency_type_id.to_s.should == @attr[:agency_type_id]
          @vendor.city.should == @attr[:city]
          @vendor.contact_no.should == @attr[:contact_no]
          @vendor.contact_person.should == @attr[:contact_person]
          @vendor.country_id.to_s.should == @attr[:country_id]
          @vendor.email.should == @attr[:email]
          @vendor.market_id.to_s.should == @attr[:market_id]
          @vendor.state_id.should == @attr[:state_id]
          @vendor.title.should == @attr[:title]
          @vendor.zipcode.should == @attr[:zipcode]
          @vendor.discipline_id.to_s.should == @attr[:discipline_id]
        end

        it "should redirect to the vendor list page" do
          put :update, :vendor => @attr, :id => @vendor
          response.should redirect_to(client_vendors_path)
        end

        it "should have a successful message" do
          put :update, :vendor => @attr, :id => @vendor
          flash[:notice].should =~ /Successfully updated./i
        end
      end
    end
  
    describe "company_vendor_delete" do
      before(:each) do
        @unused_vendor = Factory(:vendor, :id => '50f9403b6e01ed2481000009', :name => 'Unused Vendor', :contact_person => Faker::Name.name, :contact_no => Faker::PhoneNumber.phone_number, :agency_type_id => '506aea066e01ed4c1a000130', :country_id => '506aea046e01ed4c1a00005e', :discipline_id => '506aea066e01ed4c1a000131', :company_id => "506af53c6e01ed4f34000004", :market_id => "506aead66e01ed4c5700000a", :market_name => "India", :email => Faker::Internet.email)
      end

      it "should destroy the vendor" do
        expect { delete :destroy, :id => @unused_vendor }.to change(Vendor, :count).by(-1)
      end
  
      it "should redirect to the vendor list page" do
        delete :destroy, :id => @vendor.id
        response.should redirect_to(client_vendors_path)
      end

      it "should raise error because of the vendor is associated with a existing plan" do
        delete :destroy, :id => @vendor.id
        @plan.vendor_id.to_s == @vendor.id
        flash[:error].should =~ /This vendor cann't be deleted, because this vendor belongs to the exiting plan./i
        response.should redirect_to(client_vendors_path)
      end
    end
  end

  describe "setup_contract_metrics" do
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
      @vendor = Factory(:vendor)
      @request.env['HTTP_REFERER'] = "http://testing.localhost:3001/client/vendor/#{@vendor}/setup-contract-metrics"
      Factory(:agency_type)
      Factory(:discipline)
      Factory(:market)
      Factory(:company_discipline)
      Factory(:brand)
      Factory(:department)
      Factory(:job_title)
      Factory(:benchmark_salary)
      Factory(:brand_vendor)
      @vendor_job_rate = Factory(:vendor_job_rate)
      @asset = Factory(:asset)
      @attr = { :compensation_method => 'Hourly Rate (Blended)',:hours_fte => '1800.00', :overhead_rate => '50', :profit_margin => '18.0'  }
    end

    it "should be submit the form successfully." do
      visit client_setup_contract_metrics_url(:host => HOST_WITH_PORT, :subdomain => "testing", :vid => @vendor)
      within '#formID' do
        select 'Cost Plus', :from => 'vendor[compensation_method]'
        fill_in "vendor[hours_fte]", :with => '1200'
        fill_in 'vendor[overhead_rate]', :with => '1000'
        fill_in 'vendor[profit_margin]', :with => '580'
        find(:xpath, "//input[@name='vendor_spend_mix[0][spend_mix_title]']", :visible => false).set "TV-National"
        fill_in 'vendor_spend_mix[0][commission_rate]', :with => '121'
        check('vendor_spend_mix[0][media_planning]')
        check('vendor_spend_mix[0][media_buying]')
        fill_in 'vendor[blended_hourly_rate]', :with => '100'
        find(:xpath, "//input[@name='vendor_job_rates[0][discipline_id]']", :visible => false).set "506aea066e01ed4c1a000131"
        find(:xpath, "//input[@name='vendor_job_rates[0][discipline_name]']", :visible => false).set "Advertising"
        find(:xpath, "//input[@name='vendor_job_rates[0][department_id]']", :visible => false).set "506aeb2e6e01ed4c6c000001"
        find(:xpath, "//input[@name='vendor_job_rates[0][department_title]']", :visible => false).set "Account Management"
        find(:xpath, "//input[@name='vendor_job_rates[0][job_title_id]']", :visible => false).set "506aeb6f6e01ed4c7e000001"
        find(:xpath, "//input[@name='vendor_job_rates[0][job_title_name]']", :visible => false).set "Global Account Head"
        find(:xpath, "//input[@name='vendor_job_rates[0][years_of_exp]']", :visible => false).set "24"
        fill_in 'vendor_job_rates[0][hourly_rate]', :with => '12'
        find(:xpath, "//input[@name='vendor_asset_rates[0][asset_id]']", :visible => false).set "506aea836e01ed4c41000013"
        find(:xpath, "//input[@name='vendor_asset_rates[0][asset_name]']", :visible => false).set "TV Local Original (1)"
        fill_in 'vendor_asset_rates[0][gold_cost]', :with => '100'
        fill_in 'vendor_asset_rates[0][silver_cost]', :with => '80'
        fill_in 'vendor_asset_rates[0][bronze_cost]', :with => '50'
        click_on 'Save'
      end
      page.should have_content('Contract Metrics Saved Successfully.')
    end

    it "should get setup_contract_metrics" do
      get :setup_contract_metrics, :vid => @vendor
      response.should be_success
    end

    it "should get reset_job_rates" do
      get :reset_job_rates, :vid => @vendor
      response.should redirect_to @request.env['HTTP_REFERER']
    end

    it "should get reset_assets_price" do
      get :reset_assets_price, :vid => @vendor
      response.should redirect_to @request.env['HTTP_REFERER']
    end

    it "should delete reset_custom_assets_price" do
      delete :reset_custom_assets_price, :vid => @vendor
      response.should redirect_to @request.env['HTTP_REFERER']
    end
  end
end