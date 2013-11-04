FactoryGirl.define do
  factory :admin do
    email 'diganta@circarconsulting.com'
    password "admin123"
    password_confirmation "admin123"

    first_name Faker::Name.first_name
    last_name Faker::Name.last_name

  end
end