FactoryGirl.define do
  factory :plan do
    id '50b638e26e01ed377f0000e1'
    compensation '1000000.0'
    plan_no '3EA3CF3E'
    start_date Time.now
    plan_name "test"
    vendor_id "510a8b9b6e01ed2e4e00002b"
    user_id "50b608876e01ed27bb000007"
    brand_id "5194bccba85d5112dd000002"
    vendor_market_name "INDIA"
    approved true
    city Faker::Address.city
    currency_symbol 'INR'
    company_id '506af53c6e01ed4f34000004'
    vendor_market_id '506aead66e01ed4c5700000a'
    country_id '506aea046e01ed4c1a00005e'
    end_date Time.now + 10.days
    active true
  end
end