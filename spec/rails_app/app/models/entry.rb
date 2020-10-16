class Entry < ApplicationRecord
  belongs_to :room
  belongs_to :user
  validates :user, uniqueness: { scope: :room }
end
