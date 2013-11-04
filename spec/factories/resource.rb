FactoryGirl.define do
  factory :resource do
    id '521c66a9a85d5108ab000009'
    title Faker::Name.title
    description  Faker::Lorem.word
    avatar { File.new(Rails.root.join('tmp/testing.txt')) }
  end
end