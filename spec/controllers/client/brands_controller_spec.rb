require 'spec_helper'

describe Client::BrandsController do
  render_views
  
  describe "page" do
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      Factory(:company)
      visit new_user_session_url(:host => HOST_WITH_PORT, :subdomain => nil)
      user = Factory(:user, :is_admin => true)
      within("#new_user") do
        fill_in "user[email]",     :with => user.email
        fill_in "user[password]",  :with => user.password
        click_on "Login"
      end
      sign_in :user, user
    end

    describe "new_brand" do
      it "should be perform validation on form submit", :js => true do
        visit new_client_brand_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        within("#formID") do
          select "Others", :from => "brand[business_unit]"
          fill_in "other_business_unit", :with => "test"
          select "Others", :from => "brand[category]"
          fill_in "other_category", :with => "test"
          fill_in "brand_name", :with => nil
          select "Launch", :with => nil
          fill_in "brand[brand_manager]", :with => nil
          fill_in "brand[title]", :with => nil
          fill_in "brand[email]", :with => nil
          fill_in "brand[contact_no]", :with => nil
          click_on "Save"
        end
        find("div.formErrorContent").should have_content("* This field is required")
      end

      it "should be submit form successfully", :js => true do
        visit new_client_brand_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        page.should have_selector('a', :content => "Cancel")
        within("#formID") do
          select "Others", :from => "brand[business_unit]"
          fill_in "other_business_unit", :with => "test"
          select "Others", :from => "brand[category]"
          fill_in "other_category", :with => "test"
          fill_in "brand_name", :with => Faker::Lorem.word
          select "Launch", :from => "brand[lifecycle]"
          fill_in "brand[brand_manager]", :with => Faker::Name.name
          fill_in "brand[title]", :with => Faker::Name.title
          fill_in "brand[email]", :with => Faker::Internet.email
          fill_in "brand[contact_no]", :with => Faker::PhoneNumber.phone_number
          click_on "Save"
        end
        page.should have_content("Successfully created.")
      end

      it "should check the cancel functionality" do
        visit new_client_brand_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        find_link('Cancel').click
        find('div.alert-info').should have_content('Sorry! There are no brands.')
      end
    end


    describe "brand_edit" do
      it "should be perform validation on form submit", :js => true do
        brand = Factory(:brand)
        visit edit_client_brand_url(:host => HOST_WITH_PORT, :subdomain => "testing", :id => brand)
        page.should have_button('Save')
        within("#formID") do
          select "test", :from => "brand[business_unit]"
          select "test", :from => "brand[category]"
          fill_in "brand_name", :with => Faker::Lorem.word
          select "Launch", :from => "brand[lifecycle]"
          fill_in "brand[brand_manager]", :with => Faker::Name.name
          fill_in "brand[title]", :with => Faker::Name.title
          fill_in "brand[email]", :with => nil
          fill_in "brand[contact_no]", :with => Faker::PhoneNumber.phone_number
          click_on "Save"
        end
        find("div.brand_emailformError").should have_content("* This field is required")
      end

      it "should be submit form successfully", :js => true do
        brand = Factory(:brand)
        visit edit_client_brand_url(:host => HOST_WITH_PORT, :subdomain => "testing", :id => brand)
        page.should have_button('Save')
        within("#formID") do
          select "test", :from => "brand[business_unit]"
          select "test", :from => "brand[category]"
          fill_in "brand_name", :with => Faker::Lorem.word
          select "Launch", :from => "brand[lifecycle]"
          fill_in "brand[brand_manager]", :with => Faker::Name.name
          fill_in "brand[title]", :with => Faker::Name.title
          fill_in "brand[email]", :with => Faker::Internet.email
          fill_in "brand[contact_no]", :with => Faker::PhoneNumber.phone_number
          click_on "Save"
        end
        page.should have_content("Successfully updated.")
      end
    end

    describe "company_brands" do
      before(:each) do
        30.times do
          Factory(:brand, :name => Factory.next(:name), :brand_manager => Factory.next(:brand_manager), :email => Factory.next(:email))
        end
      end

      it "should be active right tab" do
        visit  client_brands_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        page.should have_selector('a', :content => "New Brand")
      end

      it "should paginate brands", :js => true do
        visit  client_brands_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        page.should have_selector('div.dataTables_paginate')
        page.should have_selector('li.disabled > a', :content => "← Previous")
        page.should have_selector('li.active > a', :content => "1")
        page.should have_selector('li.next > a', :content => "Next → ")
      end

      it "should open action dropdown", :js => true do
        visit  client_brands_url(:host => HOST_WITH_PORT, :subdomain => "testing")
        find('a.dropdown-toggle', :text => "Actions").click
        page.has_css?('ul', :class => 'dropdown-menu').should be_true
      end
    end
  end

  describe "Action" do
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      Factory(:company)
      @brand = Factory(:brand)
      @plan = Factory(:plan)
      user = Factory(:user, :is_admin => true)
      sign_in :user, user
    end
    
    describe "index" do
      it "should get index" do
        get :index
        response.should be_success
      end
    end

    describe "brand_new" do
      it "should get new" do
        get :new
        response.should be_success
      end
    end

    describe "create_brand" do
      describe "failure" do
        before(:each) do
          @attr = { :name => nil }
        end

        it "should be re-render to the brand new page" do
          post :create, :brand => @attr
          response.should render_template('new')
        end
      end

      describe "success" do
        before(:each) do
          @attr = { :name => Faker::Lorem.word, :brand_manager => Faker::Name.name, :title => Faker::Name.title, :email => Faker::Internet.email, :contact_no => Faker::PhoneNumber.phone_number, :lifecycle=> "Mature", :business_unit => "test", :category => "test" }
        end

        it "should redirect to the brand index page with the successful message after update" do
          post :update, :id => @brand.id, :brand => @attr
          flash[:notice].should =~/Successfully updated./i
          response.should redirect_to(client_brands_path)
        end

        it "should change the brand's attributes" do
          post :update, :id => @brand.id, :brand => @attr
          @brand.reload
          @brand.name.should == @attr[:name]
          @brand.brand_manager.should == @attr[:brand_manager]
          @brand.title.should == @attr[:title]
          @brand.email.should == @attr[:email]
          @brand.contact_no.should == @attr[:contact_no]
          @brand.lifecycle.should == @attr[:lifecycle]
          @brand.business_unit.should == @attr[:business_unit]
          @brand.category.should == @attr[:category]
        end

        it "should create a brand record" do
          lambda do
            post :create, :brand => @attr
          end.should change(Brand, :count).by(1)
        end

        it "should redirect to the brand list page after create" do
          post :create, :brand => @attr, :id => subject.current_user.id
          flash[:notice].should =~ /Successfully created./i
          response.should redirect_to(client_brands_path)
        end
      end
    end

    describe "company_brand_delete" do
      before(:each) do
        @unused_brand = Factory(:brand, :id => "51237b066e01ed0a2a000007", :name => "Unused Brand", :brand_manager => Faker::Name.name, :contact_no => Faker::PhoneNumber.phone_number, :title => Faker::Name.title, :email => Faker::Internet.email, :company_id => "506af53c6e01ed4f34000004")
      end

      it "should destroy the brand" do
        expect { delete :destroy, :id => @unused_brand }.to change(Brand, :count).by(-1)
      end

      it "should raise error because of the brand is associated with a exiting plan" do
        delete :destroy, :id => @brand.id
        @plan.brand_id == @brand.id
        flash[:error].should =~ /This brand cann't be deleted, because this brand belongs to the exiting plan./i
        response.should redirect_to(client_brands_path)        
      end
    end
  end
end