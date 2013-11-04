FactoryGirl.define do
  factory :page do
    title 'Privacy Policy'
    content Faker::Lorem.word
  end
end