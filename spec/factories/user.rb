FactoryGirl.define do
  factory :user do
    id '510ff1706e01ed72f600000e'
    email Faker::Internet.email
    password "123456"
    password_confirmation "123456"

    first_name Faker::Name.first_name
    last_name Faker::Name.last_name

    contact_no Faker::PhoneNumber.phone_number
    company_id "506af53c6e01ed4f34000004"
    # required if the Devise Confirmable module is used
    confirmed_at Time.now
    confirmation_token nil
    is_admin true
    is_blocked false

  end
end

Factory.sequence :email do |n|
  Faker::Internet.email("testemail#{n}")
end

Factory.sequence :first_name do |n|
  "#{Faker::Name.first_name}"
end

Factory.sequence :last_name do |n|
  "#{Faker::Name.last_name}"
end