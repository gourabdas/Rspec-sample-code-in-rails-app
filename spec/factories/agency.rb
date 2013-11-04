FactoryGirl.define do
  factory :agency do
    id '51b6c283a85d5108a5000005'
    username 'testing_gourab'
    name Faker::Name.name
    email Faker::Internet.email
    password '123456'
    password_confirmation '123456'
    company_id '506af53c6e01ed4f34000004'
    state_id '506aea3b6e01ed4c2d0003a7'
    country_id '506aea046e01ed4c1a00005e'
    vendor_id '510a8b9b6e01ed2e4e00002b'
    is_admin true
    confirmed_at Time.now
    confirmation_token nil
  end
end