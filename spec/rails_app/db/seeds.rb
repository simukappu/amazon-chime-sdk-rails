# coding: utf-8
# This file is seed file for test data on development environment.

def clean_database
  [Entry, Room, User].each do |model|
    model.delete_all
  end
end

def reset_pk_sequence
  ActiveRecord::Base.connection.execute("UPDATE sqlite_sequence SET seq = 0")
end

clean_database
puts "* Cleaned database"

reset_pk_sequence
puts "* Reset sequences for primary keys"

['Ichiro', 'Stephen', 'Klay', 'Kevin'].each do |name|
  email = "#{name.downcase}@example.com"
  user = User.create(
    email:                 email,
    password:              'changeit',
    password_confirmation: 'changeit',
    name:                  name,
    uid:                   email
  )
end
puts "* Created #{User.count} user records"

room = Room.create
puts "* Created #{Room.count} room records"

['Ichiro', 'Stephen'].each do |name|
  user = User.find_by(name: name)
  room.add_member(user)
end
puts "* Created #{Entry.count} entry records"

puts "Created amazon-chime-sdk-rails test records!"