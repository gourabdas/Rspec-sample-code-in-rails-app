FactoryGirl.define do
  factory :company_asset do
    id '51013d656e01ed31bf000005'
    asset_type 'Television'
    bronze_cost 50
    company_id '506af53c6e01ed4f34000004'
    description Faker::Lorem.word
    gold_cost 200
    name Faker::Name.title
    silver_cost 100
  end
end