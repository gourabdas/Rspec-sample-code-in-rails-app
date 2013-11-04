require 'spec_helper'

describe Admins::MasterDataController do
  render_views

  before(:each) do
    @request.host = HOST_WITH_PORT
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    @admin = Factory(:admin)
    sign_in :admin, @admin
    @company = Factory(:company)
    Factory(:country)    
  end

  describe 'Action' do
    before(:each) do
      @discipline = Factory(:discipline)
      @department = Factory(:department)
      @asset = Factory(:asset)
      @request.env['HTTP_REFERER'] = "http://admin.localhost:3000/benchmark/data/Jobs"
      @unused_job_title = Factory(:job_title, :id => '506aeb6f6e01ed4c7e000012',:years_of_exp => 8, :description  => Faker::Lorem.word, :title => 'Senior Planner')
      @metric = Factory(:metric)
      @market =  Factory(:market)
      @job_title = Factory(:job_title)
      @benchmark_metric = Factory(:benchmark_metric)
      @benchmark_salary = Factory(:benchmark_salary)
    end

    let(:asset_hour) { Factory(:asset_hour)}
    let(:benchmark_salary) { Factory(:benchmark_salary) }
    let(:asset_attr) {{:name => Faker::Name.title, :description => Faker::Lorem.word, :asset_type => 'Television'}}
    let(:market_attr) {{:country_id => @market.country_id, :name => @market.name}}
    let(:department_attr) {{:title => @department.title}}
    let(:job_title_attr) {{:description => @job_title.description, :title => @job_title.title, :years_of_exp => @job_title.years_of_exp }}

    it "should list all the benchmark data for a particular type" do
      get :list_all_benchmark_data, :type => 'asset'
      response.should be_success      
    end

    it "should list of asset rate or hour data depend on asset id" do
      get :get_asset_rate_and_hour, :_id => @asset, :a_type => 'rate'
      response.should be_success 
    end

    it "should initialize new benchmark data for a prticular type" do
      get :new_benchmark_data, :type => 'asset'
      response.should be_success
    end

    it "should get the benchmark data edit page" do
      get :edit_benchmark_data, :_id => @asset, :type => 'asset-edit'
      response.should be_success
    end

    it "should delete the benchmark salary" do
      lambda do
        delete :remove_benchmark_salary, :id => @benchmark_salary
        flash[:notice].should =~ /Record deleted successfully from Benchmark Salaries./i
        response.should redirect_to(list_all_benchmark_data_path("banchmark_salary"))
      end.should change(BenchmarkSalary,:count).by(-1)
    end

    it "should update the asset" do
      put :add_update_asset, :_id => @asset, :asset => asset_attr, :type => 'asset-edit'
      flash[:notice].should =~ /Asset has been successfully saved/i
      response.should redirect_to(list_all_benchmark_data_path(:type => "asset"))
    end

    it "should update the market" do
      put :add_update_market, :type=>"market-edit", :_id => @market, :market => market_attr
      flash[:notice].should =~ /Market has been save successfully/i
      response.should redirect_to(list_all_benchmark_data_path(:type => "market"))
    end

    it "should update the department" do
      put :add_update_department, :type => 'department-edit', :_id => @department, :department => department_attr
      flash[:notice].should =~ /Department has been save successfully/i
      response.should redirect_to(list_all_benchmark_data_path(:type => "departments"))
    end

    it "should update the job title" do
      put :add_update_job, :type => 'Job-edit', :job_title => job_title_attr, :_id => @job_title
      flash[:notice].should =~ /Job Title has been save successfully./i
      response.should redirect_to(list_all_benchmark_data_path(:type => "Jobs"))
    end

    it "should delete the job title" do
      lambda do
        delete :delete_job_titles, :id => @unused_job_title
      end.should change(JobTitle,:count).by(-1)      
    end

    it "should update the discipline" do
      put :add_update_discipline, :type => 'discipline-edit', :_id => @discipline, :discipline => Factory.attributes_for(:discipline)
      flash[:notice].should =~ /Discipline has been save successfully/i
      response.should redirect_to(list_all_benchmark_data_path(:type => "discipline"))
    end

    it "should update the metric" do
      put :add_update_metric, :type => 'metric-edit', :_id => @metric, :metric => Factory.attributes_for(:metric)
      flash[:notice].should =~ /Metric has been save successfully/i
      response.should redirect_to(list_all_benchmark_data_path(:type => "metrics"))      
    end

    it "should update asset hour" do
      put :add_update_asset_hour, :type => 'asset_hour_edit', :asset_hour => Factory.attributes_for(:asset_hour), :_id => asset_hour
      flash[:notice].should =~ /Asset Hour has been save successfully/i
      response.should redirect_to(list_all_benchmark_data_path(:type => "asset_hour"))
    end


    it "should update benchmark metric" do
      put :add_update_benchmark_metric, :_id => @benchmark_metric, :benchmark_metric => Factory.attributes_for(:benchmark_metric), :type =>"benchmark_metric_edit"
      flash[:notice].should =~ /Banchmark Metric has been save successfully/i
      response.should redirect_to(list_all_benchmark_data_path(:type => "benchmark_metrics"))      
    end


    it 'should bloc/unblock the asset' do
      get :block_unblock_assets, :type => "Unblock", :id => @asset
      flash[:notice].should =~ /Asset unblocked Successfully./i      
    end



    describe 'delete_asset' do
      before(:each) do
        Factory(:asset_hour)
        @unused_asset = Factory(:asset,:id => '506aea836e01ed4c4100000f',:name => Faker::Name.title, :description => Faker::Lorem.word, :asset_type => 'Brand Strategy')
      end
      it "should not delete the used asset, should raise an exception" do
        delete :delete_asset, :id => @asset
        flash[:error].should =~ /This asset is already used ! you can't delete./i
        response.status.should be(302)
      end

      it "should delete unused asset" do
        lambda do
          delete :delete_asset, :id => @unused_asset
        end.should change(Asset,:count).by(-1)
      end
    end

    describe 'delete_metric' do
      before(:each) do
        @unused_metric = Factory(:metric,:id => '506aebb86e01ed4c91000011',:title => Faker::Name.title)
      end
      it "should not delete the metric,as because it has been used in benchmark metric" do
        expect {
          delete :delete_metric, :id => @metric
        }.to_not change(Metric, :count)
      end
      it "should delete unused metric" do
        lambda do
          delete :delete_metric, :id => @unused_metric
        end.should change(Metric,:count).by(-1)
      end
    end

    it "should get job_title based on the discipline" do
      get :get_jobtitles, :discipline_id => @discipline
      response.body.should == "<option value='506aeb6f6e01ed4c7e000001'>Global Account Head</option>"
    end

    it "should get asset name on the basis of asset type" do
      get :select_asset_type, :asset_type => @asset.asset_type
      response.body.should == "<option value='506aea836e01ed4c41000013'>TV Local Original (1)</option>"
    end


  end
end
