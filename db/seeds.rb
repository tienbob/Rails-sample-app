# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create sample users for development/testing
unless Rails.env.production?
  puts "Creating sample users..."
  
  # Create additional users
  99.times do |n|
    name = "User #{n+1}"
    email = "example-#{n+1}@railstutorial.org"
    password = "password"
    
    User.find_or_create_by!(email: email) do |u|
      u.name = name
      u.password = password
      u.password_confirmation = password
      u.activated = true
      u.activated_at = Time.zone.now
    end
  end
  
  puts "Sample users created!"
  
  # Create sample microposts
  puts "Creating sample microposts..."
  users = User.order(:created_at).take(6)
  sample_posts = [
    "Hello world! This is my first micropost.",
    "Ruby on Rails is awesome!",
    "Learning web development one step at a time.",
    "Beautiful day for coding!",
    "Just deployed my app to production.",
    "Coffee and code - perfect combination.",
    "Working on some exciting features.",
    "Love the Rails community!",
    "Building something amazing.",
    "Another productive day!"
  ]
  
  10.times do |i|
    content = sample_posts[i % sample_posts.length]
    users.each { |user| user.microposts.create!(content: "#{content} ##{i+1}") }
  end
  
  puts "Sample microposts created!"

# Create following relationships.
users = User.all
user = users.first
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow_user(followed) }
followers.each { |follower| follower.follow_user(user) }
end

puts "Seeding complete!"
