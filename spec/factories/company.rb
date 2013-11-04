FactoryGirl.define do
  factory :company do
    id "506af53c6e01ed4f34000004"
    name Faker::Company.name
    subdomain "testing"
    address1 Faker::Address.street_name
    zip Faker::Address.zip_code
    city Faker::Address.city
    country_id "506aea046e01ed4c1a00005e"
    address2 nil
    is_blocked false
    formatted_date "%d/%m/%Y"
    state_id "506aea3b6e01ed4c2d0003a7"
    industry_type_id "506aea046e01ed4c1a00005e"
    other_industry_type nil
  end
end