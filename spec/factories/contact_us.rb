FactoryGirl.define do
  factory :contact_us do
    id '511ce2356e01ed1c6c000018'
    email Faker::Internet.email
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    contact_no Faker::PhoneNumber.phone_number
    address1 Faker::Address.street_name
    zip Faker::Address.zip_code
    city Faker::Address.city
    company_name Faker::Company.name
    country_id "506aea046e01ed4c1a00005e"
  end
end

