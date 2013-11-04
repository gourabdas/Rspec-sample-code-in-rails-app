FactoryGirl.define do
  factory :vendor do
    id '510a8b9b6e01ed2e4e00002b'
    address1 Faker::Address.secondary_address
    address2 nil
    agency_portal false
    agency_type_id '506aea066e01ed4c1a000130'
    city Faker::Address.city
    company_id '506af53c6e01ed4f34000004'
    contact_no Faker::PhoneNumber.phone_number
    contact_person Faker::Name.name
    country_id '506aea046e01ed4c1a00005e'
    email Faker::Internet.email
    market_id '506aead66e01ed4c5700000a'
    market_name 'India'
    name "Test"
    state_id nil
    title "Testing"
    zipcode Faker::Address.zip_code
    discipline_id '506aea066e01ed4c1a000131'
  end
end