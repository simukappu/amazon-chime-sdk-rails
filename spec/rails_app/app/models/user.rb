class User < ApplicationRecord
  devise :database_authenticatable, :registerable
  include DeviseTokenAuth::Concerns::User
  has_many :entries, dependent: :destroy
  validates_uniqueness_of :name
end
