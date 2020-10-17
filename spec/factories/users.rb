FactoryBot.define do
  factory :user do
    name { Array.new(10){[*"A".."Z", *"0".."9"].sample}.join }
    email { name + '@example.com' }
    password { "password" }
    password_confirmation { "password" }
  end
end