require 'spec_helper'

describe Admins::ResourcesController do
  render_views

  before(:each) do
    @request.host = HOST_WITH_PORT
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    @admin = Factory(:admin)
    sign_in :admin, @admin
    @company = Factory(:company)
    Factory(:vendor)
  end

  describe 'Action' do
    before(:each) do
      @resource_attr = { :title => Faker::Name.title, :description => Faker::Lorem.paragraph }
      path = File.join(Rails.root, "tmp", "testing.txt").to_s
      File.open(path, "w") unless File.exist?(path)
      avatar = Rack::Test::UploadedFile.new(path)
      @attr = { :title => Faker::Name.title, :description => Faker::Lorem.paragraph, :avatar => avatar }
      @resource = Factory(:resource)
      @agency = Factory(:agency)
    end
    
    let(:mail) { UserMailer.notify_agency([@agency]) }

    it "should get the resource index page" do
      get :index
      response.should be_success
    end

    it "should show the log for each given type" do
      get :view_log, :type => "Assets Log"
      response.should render_template :partial => "admins/resources/_view_log"
    end

    it "should get resources new page" do
      get :new
      response.should be_success
    end

    it "should create a new resource" do
      post :create, :resource => @attr
      flash[:notice].should =~ /Resource has been successfully created./i
      response.should redirect_to(admins_resources_path)
    end

    it "should get resource edit page" do
      get :edit, :id => @resource
      response.should be_success
    end

    it "should update the resource and should redirect to resource list page" do
      put :update, :resource => @resource_attr , :id => @resource
      flash[:notice].should =~ /Resource has been successfully updated./i
      response.should redirect_to(admins_resources_path)
    end

    it "should change the resource attributes" do
      put :update, :resource => @resource_attr , :id => @resource
      @resource.reload
      @resource.title.should == @resource_attr[:title]
      @resource.description.should == @resource_attr[:description]  
    end

    it "should delete the resource" do
      lambda do
        delete :destroy, :id => @resource
      end.should change(Resource,:count).by(-1)
    end

    it "should download the resource description" do
      get :download, :id => @resource
      response.headers["Content-Type"].should == "text/plain"
    end

    it "should notify to agency" do
      get :notify_agencies
      mail.to.should == [@agency[:email]]
      mail.from.should == ["do-not-reply@rightspend.com"]
      mail.subject.should == "Changed sign in process of agency user."
      flash[:notice].should =~ /Successfully informed all agency users./i
      response.should redirect_to(root_path)
    end
  end
end