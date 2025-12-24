# Seeds for Development Only
if Rails.env.development?

  puts "Seeding AdminUser..."
  AdminUser.find_or_create_by!(email: "admin@example.com") do |admin|
    admin.password = "password"
    admin.password_confirmation = "password"
  end

  puts "Seeding Users..."
  user = User.find_or_create_by!(email: "user1@example.com") do |u|
    u.password = "password123"
  end

  puts "Seeding Events..."
  event = Event.find_or_create_by!(title: "Sample Event") do |e|
    e.description = "A sample event for development testing"
    e.date = Date.today + 7
    e.location = "Lahore"
    e.price = 0
  end

  puts "Seeding Registration..."
  Registration.find_or_create_by!(user: user, event: event)

  puts "Seeding Event Requests..."
  EventRequest.find_or_create_by!(email: "ali@example.com", event_title: "Tech Meetup Lahore") do |req|
    req.name = "Ali Khan"
    req.phone = "0312-000000"
    req.event_description = "A meetup on Rails and JS"
    req.preferred_date = Date.tomorrow + 14
    req.preferred_time = "18:00 - 21:00"
    req.is_remote = false
    req.venue_address = "Expo Center, Lahore"
  end

  puts "✔ Seeding completed successfully!"
end

# Categories
categories = [
  { name: 'Sports' },
  { name: 'Tech' },
  { name: 'Concerts' },
  { name: 'Parties' },
  { name: 'Conferences' },
  { name: 'Workshops' },
  { name: 'Networking' },
  { name: 'Food & Drink' }
]

puts "Creating categories..."
categories.each do |category_data|
  category = Category.find_or_create_by(name: category_data[:name])
  puts "Created: #{category.name}"
end

puts "Categories created successfully!"
