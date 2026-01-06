# Clear existing data (optional - comment out if you want to keep existing data)
puts "🧹 Cleaning up old data (keeping existing events and users)..."
# Ticket.destroy_all # Uncomment to clear tickets
# Registration.destroy_all # Uncomment to clear registrations

puts "=" * 60
puts "🌱 Starting Data Seeding Process..."
puts "=" * 60

# ============================================================================
# 1. ADMIN USER
# ============================================================================
puts "\n👤 Creating Admin User..."
admin = AdminUser.find_or_create_by!(email: "admin@example.com") do |a|
  a.password = "password"
  a.password_confirmation = "password"
end
puts "✓ Admin created: #{admin.email}"

# ============================================================================
# 2. CATEGORIES
# ============================================================================
puts "\n📂 Creating Categories..."
categories_data = [
  'Music', 'Sports', 'Technology', 'Arts & Culture',
  'Concerts', 'Parties', 'Conferences', 'Workshops',
  'Networking', 'Food & Drink', 'Education', 'Health & Wellness'
]

categories = {}
categories_data.each do |cat_name|
  cat = Category.find_or_create_by!(name: cat_name)
  categories[cat_name] = cat
  puts "  ✓ #{cat_name}"
end

# ============================================================================
# 3. USERS (Attendees)
# ============================================================================
puts "\n👥 Creating Users..."

users_data = [
  { email: "john.doe@example.com", name: "John Doe" },
  { email: "sarah.smith@example.com", name: "Sarah Smith" },
  { email: "ahmed.khan@example.com", name: "Ahmed Khan" },
  { email: "fatima.ali@example.com", name: "Fatima Ali" },
  { email: "michael.brown@example.com", name: "Michael Brown" },
  { email: "aisha.malik@example.com", name: "Aisha Malik" },
  { email: "david.wilson@example.com", name: "David Wilson" },
  { email: "zainab.hassan@example.com", name: "Zainab Hassan" },
  { email: "robert.taylor@example.com", name: "Robert Taylor" },
  { email: "maryam.ahmed@example.com", name: "Maryam Ahmed" },
  { email: "james.anderson@example.com", name: "James Anderson" },
  { email: "hira.shah@example.com", name: "Hira Shah" },
  { email: "william.thomas@example.com", name: "William Thomas" },
  { email: "ayesha.raza@example.com", name: "Ayesha Raza" },
  { email: "richard.jackson@example.com", name: "Richard Jackson" }
]

users = []
users_data.each do |user_data|
  user = User.find_or_create_by!(email: user_data[:email]) do |u|
    u.name = user_data[:name]
    u.password = "Password@2024"
    u.password_confirmation = "Password@2024"
    u.confirmed_at = Time.now # Auto-confirm for testing
  end
  users << user
  puts "  ✓ #{user_data[:name]} (#{user.email})"
end

# Keep existing users
existing_users = User.where.not(email: users_data.map { |u| u[:email] })
users += existing_users.to_a
puts "  ✓ Loaded #{existing_users.count} existing users"

# ============================================================================
# 4. UPDATE EXISTING EVENTS WITH CAPACITY
# ============================================================================
puts "\n🎫 Updating Existing Events with Capacity..."

Event.find_each do |event|
  if event.event_capacity.nil?
    # Set realistic capacity based on event type
    capacity = case event.price.to_f
    when 0 then rand(100..500) # Free events have more capacity
    when 1..100 then rand(50..200)
    when 101..500 then rand(30..100)
    else rand(20..80)
    end

    event.update_columns(event_capacity: capacity)
    puts "  ✓ #{event.title}: capacity set to #{capacity}"
  end
end

# ============================================================================
# 5. CREATE TICKETS FOR EXISTING EVENTS
# ============================================================================
puts "\n🎟️  Generating Ticket Purchases..."

# Get all events with capacity
events_with_capacity = Event.where.not(event_capacity: nil)

total_tickets_created = 0
total_revenue = 0

events_with_capacity.each do |event|
  # Determine how many tickets to sell (60-90% of capacity)
  capacity = event.event_capacity
  tickets_to_sell = (capacity * rand(0.6..0.9)).to_i

  puts "\n  📅 Event: #{event.title}"
  puts "     Capacity: #{capacity}, Selling: #{tickets_to_sell} tickets"

  tickets_sold = 0
  attempts = 0
  max_attempts = tickets_to_sell * 2 # Prevent infinite loop

  while tickets_sold < tickets_to_sell && attempts < max_attempts
    attempts += 1

    # Random user buys ticket(s)
    buyer = users.sample

    # Random quantity (1-5 tickets, but respect capacity)
    remaining = tickets_to_sell - tickets_sold
    quantity = [rand(1..5), remaining].min

    # Determine ticket type
    ticket_type = if event.has_multiple_ticket_types? && event.ticket_types_data.present?
      # Pick from available types
      event.ticket_types_data.keys.sample
    else
      'Standard'
    end

    # Calculate price
    price_per_ticket = if event.has_multiple_ticket_types? && event.ticket_types_data.present?
      event.ticket_types_data[ticket_type] || event.price || 0
    else
      event.price || 0
    end

    total_amount = price_per_ticket * quantity

    # Create ticket (skip if user already bought this ticket type for this event)
    existing_ticket = Ticket.find_by(user: buyer, event: event, ticket_type: ticket_type)

    if existing_ticket.nil?
      # Random status (90% paid, 10% pending)
      status = rand < 0.9 ? 'paid' : 'pending'

      # Random payment method
      payment_methods = ['credit_card', 'debit_card', 'paypal']
      payment_method = payment_methods.sample

      # Random date in the past 30 days
      created_at = rand(30.days.ago..Time.now)

      # Create registration first
      registration = Registration.find_or_create_by!(user: buyer, event: event) do |reg|
        reg.status = 'registered'
        reg.created_at = created_at
      end

      ticket = Ticket.create!(
        user: buyer,
        event: event,
        registration: registration,
        ticket_type: ticket_type,
        quantity: quantity,
        total_amount: total_amount,
        status: status,
        payment_method: payment_method,
        payment_id: status == 'paid' ? "pay_#{SecureRandom.hex(12)}" : nil,
        created_at: created_at,
        updated_at: created_at
      )

      tickets_sold += quantity
      total_tickets_created += 1
      total_revenue += total_amount if status == 'paid'

      puts "     ✓ #{buyer.email.split('@').first} bought #{quantity}x #{ticket_type} - $#{total_amount} (#{status})"
    end
  end

  puts "     📊 Total sold: #{tickets_sold}/#{tickets_to_sell}"
end

# Registrations are created automatically with tickets

# ============================================================================
# 7. STATISTICS
# ============================================================================
puts "\n" + "=" * 60
puts "📊 SEEDING COMPLETE!"
puts "=" * 60

puts "\n📈 Database Statistics:"
puts "  • Admin Users:      #{AdminUser.count}"
puts "  • Categories:       #{Category.count}"
puts "  • Users:            #{User.count}"
puts "  • Events:           #{Event.count}"
puts "  • Event Requests:   #{EventRequest.count}"
puts "  • Tickets:          #{Ticket.count} (#{Ticket.paid.count} paid, #{Ticket.pending.count} pending)"
puts "  • Registrations:    #{Registration.count}"

puts "\n💰 Revenue Statistics:"
puts "  • Total Revenue:    $#{Ticket.paid.sum(:total_amount).round(2)}"
puts "  • Pending Revenue:  $#{Ticket.pending.sum(:total_amount).round(2)}"
puts "  • Total Tickets:    #{Ticket.sum(:quantity)}"

puts "\n🎫 Ticket Breakdown:"
Ticket::TICKET_TYPES.each do |type|
  count = Ticket.where(ticket_type: type).sum(:quantity)
  revenue = Ticket.paid.where(ticket_type: type).sum(:total_amount)
  puts "  • #{type.ljust(10)}: #{count.to_s.rjust(4)} tickets, $#{revenue.round(2)}"
end

puts "\n" + "=" * 60
puts "✅ Seed data created successfully!"
puts "=" * 60
puts "\n🔐 Admin Login:"
puts "  Email:    admin@example.com"
puts "  Password: password"
puts "  URL:      http://localhost:3000/admin"
puts "\n"
