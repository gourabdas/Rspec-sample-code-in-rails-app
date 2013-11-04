require 'spec_helper'

describe Admins::ManageClientsController do
  render_views
  
  before(:each) do
    @request.host = HOST_WITH_PORT
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    admin = Factory(:admin)
    sign_in :admin, admin
    @contact_us = Factory(:contact_us)
    @company = Factory(:company)
    @request.env['HTTP_REFERER'] = "http://admin.localhost:3000/client/#{@company}/user/create"
    @user = Factory(:user)
    @user_attr = {
      :email => Faker::Internet.email,
      :first_name => Faker::Name.first_name,
      :last_name => Faker::Name.last_name,
      :contact_no => Faker::PhoneNumber.phone_number,
      :address1 => Faker::Address.street_name,
      :country_id => "506aea046e01ed4c1a00005e",
      :password => "123456",
      :password_confirmation => "123456"
    }
    @company_attr = {
      :name => @contact_us.company_name,
      :subdomain => 'test'
    }
    @attr = {:first_name => Faker::Name.first_name, :email => nil, :last_name => Faker::Name.last_name}
    Factory(:country)
  end


  describe 'Action' do

    describe 'index' do
      it "should add new client from admin" do
        get :index, :type => 'add'
        response.should be_success
      end

      it "should list the client" do
        get :index, :type => 'list'
        response.should be_success
      end

      it "should get the edit page of the company" do
        get :index, :type => 'edit', :_id => @company.id
        response.should be_success
      end
      
    end


    describe 'my_account' do
      before(:each) do
        @my_account = {:email => 'gourab@circarconsulting.com', :first_name => Faker::Name.first_name, :last_name => Faker::Name.last_name }
      end
      it "should get my account page" do
        get :my_account, :type => 'edit'
        response.should be_success
      end

      it "should update the admin account" do
        post :my_account, :type => 'edit', :oper => 'edit', :admin => @my_account
        response.should be_success
      end
    end


    describe "complete_pending_registration" do
      it "should add company from pending registration list" do
        get :pending_registration, :id => @contact_us.id
        response.should be_success
      end
      it "should complete pending registration from admin section" do
        post :complete_pending_registration, :id => @contact_us.id, :company => @company_attr, :user => @user_attr
        flash[:notice].should =~ /Company has been successfully created./i
        response.should redirect_to(user_details_path)
      end
    end

    describe "client_add_update_delete" do
      it "should update the client details" do
        post :client_add_update_delete, :oper => 'edit', :company => @company_attr, :_id => @company.id
        flash[:notice].should =~ /Company details has been updated successfully /i
        response.should redirect_to(manage_clients_path(:type=>"list"))
      end
    
      it "should add the company" do
        post :client_add_update_delete, :oper => 'add', :company => @company_attr, :contact_id => @contact_us.id, :user => @user_attr
        flash[:notice].should =~ /Company has been created successfully./i
        response.should redirect_to(manage_clients_path(:type=>"list"))
      end
    
      it "should delete the company" do
        lambda do
          delete :client_add_update_delete, :oper => 'del', :_id => @company
        end.should change(Company, :count).by(-1)
      end
    end

    describe "client_list" do
      it "should lists the all users of the company" do
        get :company_users, :id => @company
        response.should be_success
      end

      it "should block the company" do
        put :is_blocked_user, :_id => @company
        parse_json = JSON(response.body)
        parse_json["success"].should == true
      end

      it "should initialize new user for a particular company" do
        get :company_user_new, :id => @company
        response.should be_success
      end

      it "should get the user page of a particular company"  do
        get :company_user_edit, :id => @company, :uid => @user
        response.should be_success
      end

      it "should delete the company user" do
        lambda do
          delete :company_user_delete, :id => @company, :uid => @user
        end.should change(User, :count).by(-1)
      end

      it "should give admin privilege to the user" do
        get :company_user_privilege, :id => @company, :uid => @user
        flash[:notice].should =~ /Successfully saved user privilege./i
        response.should redirect_to(company_users_list_path(@company))
      end

      it "should give permission like setup, report,etc to user" do
        get :user_permission, :_id => @user
        parse_json = JSON(response.body)
        parse_json["success"].should == true
      end

      it "should send client notification to all users" do
        post :send_notification, :user_ids => @user.id, :message => "testing"
        mail = ActionMailer::Base.deliveries.last
        mail.should deliver_to(@user[:email])
        mail.should deliver_from("RightSpend <do-not-reply@rightspend.com>")
        response.body.should == "successtrue"
      end

      it "should show the user details" do
        get :user_details
        response.should be_success
      end

      it "should delete the user from contact us table" do
        lambda do
          delete :delete_user, :id => @contact_us.id
        end.should change(ContactUs, :count).by(-1)
      end

      it "should confirm client from client list" do
        get :client_confirmation, :_id => @company.id
        flash[:notice].should =~ /Your account is already activated./i
        response.should redirect_to(manage_clients_path(:type=>"list"))
      end

      it "should not resend confirmation instrauction to the already activated client users" do
        post :resend_confirmation_instructions, :id => @user
        parse_json = JSON(response.body)
        parse_json["message"].should == 'This account has been already activated, instead of this you want to send confirmation instructions again.'
      end

      it "should block/unblock user from admins ection" do
        get :block_unblock, :id  => @user
        response.status.should be(302)
      end

      it "should login as super admin to any client section from admin panel"do
        get :login_as_a_super_admin, :id => @company
        token = @company.super_admin.authentication_token        
        response.should redirect_to(valid_user_url(token, :subdomain => @company.subdomain))
      end
    end

    describe "company_user_create" do
      describe "failure" do
        it "should not create a user and should redirect back to the page" do
          post :company_user_create, :id => @company, :user => @attr
          response.should redirect_to @request.env['HTTP_REFERER']
        end
      end
    
      describe "success" do
        it "should successfully create a new user of a particular company" do
          post :company_user_create, :id => @company, :user => @user_attr
          response.should redirect_to(company_users_list_path(@company))
        end
      end
    end
    


    describe "company_user_update" do
      describe "success" do
        it "should update the user of a particular company" do
          put :company_user_update, :id => @company, :uid => @user, :user => @user_attr
          flash[:notice].should =~ /User update has been successfully/i
          response.should redirect_to(company_users_list_path(@company))
        end
    
        it "should change the user attributes" do
          put :company_user_update, :id => @company, :uid => @user, :user => @user_attr
          @user.reload
          @user.email.should.equal?(@user_attr[:email])
          @user.first_name.should == @user_attr[:first_name]
          @user.last_name.should == @user_attr[:last_name]
          @user.contact_no.should == @user_attr[:contact_no]
          @user.address1.should == @user_attr[:address1]
          @user.country_id.to_s.should == @user_attr[:country_id]
          @user.password.should == @user_attr[:password]
          @user.password_confirmation.should == @user_attr[:password_confirmation]
        end
      end
    
      describe "failure" do
        it "should not update the user attributes" do
          put :company_user_update, :id => @company, :uid => @user, :user => @attr
          response.status.should be(302)
        end
      end
    end


    describe 'client_settings' do
      it "should set client setting for a particular company" do
        get :client_settings, :cid => @company
        response.should be_success
      end

      it "should save client setting" do
        put :save_client_settings, :cid => @company
        flash[:notice].should =~ /Client settings saved successfully./i
        response.should redirect_to(manage_clients_path("list"))
      end
    end


    describe "subdomain_status" do
      it "should check subdomain status, and the given subdomain should not be avialable" do
        post :subdomain_status, :subdomain => 'testing'
        response.body.should == "<span style='color:#EE0101;'>not available</span>"
      end

      it "should check subdomain status, and the given subdomain should be avialable" do
        post :subdomain_status, :subdomain => 'test'
        response.body.should == "<span style='color:#0088CC'>available</span>"        
      end
    end

  end

end
