FactoryGirl.define do
  factory :brand do
    id  '5194bccba85d5112dd000002'
    name 'test'
    brand_manager Faker::Name.name
    title 'Business'
    email Faker::Internet.email
    contact_no Faker::PhoneNumber.phone_number
    lifecycle 'Mature'
    business_unit 'test'
    category 'test'
    company_id "506af53c6e01ed4f34000004"
  end
end

Factory.sequence :name do |n|
  "#{Faker::Lorem.word}-#{n}"
end

Factory.sequence :brand_manager do |n|
  "#{Faker::Name.name}#{n}"
end

