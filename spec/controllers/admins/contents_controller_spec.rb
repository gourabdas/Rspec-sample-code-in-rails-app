require 'spec_helper'

describe Admins::ContentsController do
  render_views

  before(:each) do
    @request.host = HOST_WITH_PORT
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    @admin = Factory(:admin)
    sign_in :admin, @admin
    @company = Factory(:company)
  end

  describe "Actions" do

    before(:each) do
      @content_attributes = {:content => "test"}
      @page = Factory(:page)
    end

    it "should get the content page based on the type" do
      get :new, :type => 'home'
      response.should be_success      
    end

    it "should create a new content" do
      post :create_or_update, :type => 'privacy-policy', :page => @content_attributes
      response.should redirect_to(admins_contents_path('privacy-policy'))
    end

    it "should update the new content" do
      put :create_or_update, :type => 'privacy-policy', :page => @content_attributes
      @page.reload
      @page.content.should == @content_attributes[:content]
      response.should redirect_to(admins_contents_path('privacy-policy'))
    end

    it "should destroy page content" do
      expect{
        delete :destroy, :type => 'privacy-policy'
        response.should redirect_to(admins_contents_path('privacy-policy'))
          }.to change(Page,:count).by(-1)           
    end    

  end



end
