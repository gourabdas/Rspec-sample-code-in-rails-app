require 'spec_helper'

describe Client::AssetsController do
  render_views

  describe 'page' do
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
      Factory(:asset)
    end

    describe 'asset_index' do
      it "should get the index page", :js => true do
        visit client_assets_url(:host => HOST_WITH_PORT, :subdomain => 'testing')
        page.find('div.alert-info').should have_content('Sorry! There are no assets')
      end
    end

    describe "new_asset" do
      it "should be perform form validation on form submit", :js => true do
        country = Factory(:country)
        visit new_client_asset_url(:host => HOST_WITH_PORT, :subdomain => 'testing')
        country.get_currency_symbol.should == 'INR'
        within('#formID') do
          fill_in 'company_asset[name]', :with => nil
          select 'Others', :from =>'company_asset[asset_type]'
          fill_in 'other_asset_type', :with => Faker::Lorem.word
          fill_in 'company_asset[description]', :with => Faker::Lorem.paragraph
          click_on 'Save'
        end
        page.find('.company_asset_nameformError').should have_content('* This field is required')
      end

      it "should be submit form successfully", :js => true do
        country = Factory(:country)
        visit new_client_asset_url(:host => HOST_WITH_PORT, :subdomain => 'testing')
        country.get_currency_symbol.should == 'INR'
        within('#formID') do
          fill_in 'company_asset[name]', :with => Faker::Lorem.word
          select 'Others', :from =>'company_asset[asset_type]'
          fill_in 'other_asset_type', :with => Faker::Lorem.word
          fill_in 'company_asset[description]', :with => Faker::Lorem.paragraph
          click_on 'Save'
        end
      end
    end

    describe 'asset_edit' do
      it "should be form submit successfully", :js => true do
        company_asset = Factory(:company_asset)
        Factory(:country)
        visit edit_client_asset_url(:host => HOST_WITH_PORT, :subdomain => 'testing', :id => company_asset.id)
        within('#formID') do
          fill_in 'company_asset[name]', :with => Faker::Lorem.word
          select 'Others', :from =>'company_asset[asset_type]'
          fill_in 'other_asset_type', :with => Faker::Lorem.word
          fill_in 'company_asset[description]', :with => Faker::Lorem.paragraph
          click_on 'Save'
        end
        page.should have_content('Asset updated successfully.')
      end

      it "should be perform form validation on form submit", :js => true do
        company_asset = Factory(:company_asset)
        Factory(:country)
        visit edit_client_asset_url(:host => HOST_WITH_PORT, :subdomain => 'testing', :id => company_asset.id)
        within('#formID') do
          fill_in 'company_asset[name]', :with => nil
          select 'Others', :from =>'company_asset[asset_type]'
          fill_in 'other_asset_type', :with => Faker::Lorem.word
          fill_in 'company_asset[description]', :with => Faker::Lorem.paragraph
          click_on 'Save'
        end
        page.find('.company_asset_nameformError').should have_content('* This field is required')
      end
    end
  end

  describe 'Action' do
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @company = Factory(:company)
      user = Factory(:user, :is_admin => true)
      sign_in :user, user
      @asset = Factory(:asset)
      @company_asset = Factory(:company_asset)
      @attr = { :asset_type => 'Television', :description => Faker::Lorem.paragraph, :name => Faker::Lorem.word }
    end

    describe "index" do
      it "should get index" do
        get :index
        response.should be_success
      end
    end

    describe 'new' do
      it "should get new" do
        get :new
        response.should be_success
      end
    end

    describe 'create_asset' do
      describe 'success' do
        it "should redirect to the asset list page" do
          post :create, :company_asset => @attr
          flash[:notice].should =~ /Asset created successfully./i
          response.should redirect_to(client_assets_path)          
        end
    
        it "should create a new asset" do
          lambda do
            post :create, :company_asset => @attr
          end.should change(CompanyAsset, :count).by(1)
        end
      end

      describe 'failure' do
        before(:each) do
          @attr ={:name => nil}
        end

        it "should render to the asset new page" do
          post :create, :company_asset => @attr
          response.should render_template('new')
        end
      end
    end

    describe 'asset_edit' do
      it "should get asset edit" do
        get :edit, :company_asset => @company_asset, :id => @company_asset.id
        response.should be_success
      end

      it "should successfully update the asset" do
        put :update, :company_asset => @attr, :id => @company_asset.id
        @company_asset.reload
        @company_asset.asset_type.should == @attr[:asset_type]
        @company_asset.name.should == @attr[:name]
        @company_asset.description.should == (@attr[:description])
      end
    end

    describe "custom_asset_delete" do
      it "should delete custom asset" do
        expect { delete :destroy, :id => @company_asset }.to change(CompanyAsset, :count).by(-1)
      end

      it "should redirect to the custom asset listing page." do
        delete :destroy, :id => @company_asset
        response.should redirect_to(client_assets_path)
      end
    end
  end
end

