FactoryGirl.define do
 factory :benchmark_salary do
    id '506aef0e6e01ed4de4000014'
    annual_rate '1308363'
    department_id '506aeb2e6e01ed4c6c000001'
    department_title 'Account Management'
    description Faker::Lorem.word
    discipline_id '506aea066e01ed4c1a000131'
    discipline_name 'Advertising'
    hourly_rate '1688.46'
    hours_fte '1960.0'
    job_title_id '506aeb6f6e01ed4c7e000001'
    job_title_name 'Global Account Head'
    market_id '506aead66e01ed4c5700000a'
    market_name 'India'
    overhead_rate '1.15'
    profit_margin '0.15'
    years_of_exp '10'
    tier '1'
  end
end