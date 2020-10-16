class Room < ApplicationRecord
  has_many :entries, dependent: :destroy
  has_many :members, through: :entries, source: :user

  def add_member(user)
    entries.create(user: user)
  end

  def member?(user)
    members.include?(user)
  end
end
