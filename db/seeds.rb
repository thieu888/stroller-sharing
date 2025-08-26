# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Création des données de test..."

# Création des stations
stations_data = [
  { name: "Station République", gps_lat: 48.8675, gps_lng: 2.3634, capacity: 15 },
  { name: "Station Châtelet", gps_lat: 48.8588, gps_lng: 2.3469, capacity: 20 },
  { name: "Station Bastille", gps_lat: 48.8532, gps_lng: 2.3692, capacity: 12 },
  { name: "Station Montparnasse", gps_lat: 48.8414, gps_lng: 2.3206, capacity: 18 },
  { name: "Station Gare du Nord", gps_lat: 48.8808, gps_lng: 2.3548, capacity: 25 }
]

stations = []
stations_data.each do |station_data|
  station = Station.find_or_create_by(name: station_data[:name]) do |s|
    s.gps_lat = station_data[:gps_lat]
    s.gps_lng = station_data[:gps_lng]
    s.capacity = station_data[:capacity]
  end
  stations << station
  puts "✅ Station créée: #{station.name}"
end

# Création des poussettes
strollers_data = []
stations.each_with_index do |station, station_index|
  stroller_count = rand(5..10) # Entre 5 et 10 poussettes par station
  
  stroller_count.times do |i|
    qr_code = "STR#{station_index + 1}#{format('%03d', i + 1)}"
    strollers_data << {
      qr_code: qr_code,
      station: station,
      battery_level: rand(20..100),
      status: ['available', 'available', 'available', 'in_use', 'maintenance'].sample,
      gps_lat: station.gps_lat + rand(-0.001..0.001),
      gps_lng: station.gps_lng + rand(-0.001..0.001)
    }
  end
end

strollers = []
strollers_data.each do |stroller_data|
  stroller = Stroller.find_or_create_by(qr_code: stroller_data[:qr_code]) do |s|
    s.station = stroller_data[:station]
    s.battery_level = stroller_data[:battery_level]
    s.status = stroller_data[:status]
    s.gps_lat = stroller_data[:gps_lat]
    s.gps_lng = stroller_data[:gps_lng]
  end
  strollers << stroller
end

puts "✅ #{strollers.count} poussettes créées"

# Création d'un utilisateur de test
test_user = User.find_or_create_by(email: "test@example.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.full_name = "Utilisateur Test"
  u.phone_number = "0123456789"
  u.is_active = true
end

puts "✅ Utilisateur de test créé: #{test_user.email}"

# Création de quelques trajets de test
available_strollers = strollers.select { |s| s.status == 'available' }
in_use_strollers = strollers.select { |s| s.status == 'in_use' }

# Trajets terminés
3.times do |i|
  stroller = available_strollers.sample
  next unless stroller
  
  start_time = rand(1..30).days.ago
  end_time = start_time + rand(10..120).minutes
  duration_minutes = ((end_time - start_time) / 60).ceil
  cost = 1.0 + (duration_minutes * 0.15)
  
  ride = Ride.find_or_create_by(
    user: test_user,
    stroller: stroller,
    start_time: start_time
  ) do |r|
    r.end_time = end_time
    r.cost = cost
    r.status = 'completed'
    r.start_lat = stroller.station.gps_lat + rand(-0.01..0.01)
    r.start_lng = stroller.station.gps_lng + rand(-0.01..0.01)
    r.end_lat = stroller.station.gps_lat + rand(-0.01..0.01)
    r.end_lng = stroller.station.gps_lng + rand(-0.01..0.01)
  end
end

puts "✅ Trajets de test créés"

puts "🎉 Seed terminé avec succès!"
puts ""
puts "📊 Résumé:"
puts "- #{Station.count} stations"
puts "- #{Stroller.count} poussettes"
puts "- #{User.count} utilisateur(s)"
puts "- #{Ride.count} trajet(s)"
puts ""
puts "🔑 Compte de test:"
puts "Email: test@example.com"
puts "Mot de passe: password123"
