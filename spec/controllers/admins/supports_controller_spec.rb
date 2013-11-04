require 'spec_helper'

describe Admins::SupportsController do

  render_views

  before(:each) do
    @request.host = HOST_WITH_PORT
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    @admin = Factory(:admin)
    sign_in :admin, @admin
    @company = Factory(:company)
  end

  describe 'Action' do    

    before(:each) do
      @support_attr = {:password => '123456', :password_confirmation => '123456',:email => Faker::Internet.email}
      @support = Factory(:support)
    end

    it "should get the supports index page" do
      get :index
      response.should be_success   
    end

    it "should get supports new page" do
      get :new
      response.should be_success
    end

    it "should create a new support" do
      post :create, :support => @support_attr
      mail = ActionMailer::Base.deliveries.last
      mail.to.should == [@support_attr[:email]]
      mail.from.should == ['do-not-reply@rightspend.com']
      flash[:notice].should =~ /Support team user created successfully./i
      response.should redirect_to(admins_supports_path)
    end

    it "should get edit support page" do
      get :edit, :id => @support
      response.should be_success
    end

    it "should update the support" do
      put :update, :id => @support, :support => Factory.attributes_for(:support)
      flash[:notice].should =~ /Support team user updated successfully./i
      response.should redirect_to(admins_supports_path)
    end

    it "should block the support member" do
      get :block, :id => @support
      @support.reload
      @support.is_blocked.should == true
      flash[:notice].should =~ /Support team user blocked successfully./
      response.should redirect_to(admins_supports_path)
    end

    it "should unblock the support member" do
      get :unblock, :id => @support
      @support.reload
      @support.is_blocked.should == false
      flash[:notice].should =~ /Support team user unblocked successfully./
      response.should redirect_to(admins_supports_path)
    end
    
    it "should destroy the support member" do
      lambda do
        delete :destroy, :id => @support
        flash[:notice].should =~ /Support team user deleted successfully./i
        response.should redirect_to(admins_supports_path)
      end.should change(Support, :count).by(-1)
    end

    it "should send notification to the support team user" do
      post :notifications, :support_ids => @support, :message => "test"
      mail = ActionMailer::Base.deliveries.last
      mail.to.should == [@support[:email]]
      mail.from.should == ['do-not-reply@rightspend.com']
      response.should render_template('admins/mailer/send_support_team_notification')
      parse_json = JSON(response.body)
      parse_json["message"].should == 'Message has been delivered successfully.'
    end   

  end



end
