require "CSV"

puts "["

CSV.foreach("senate.csv",{:headers => true}) do |row|
  puts "#{row[4]},"
end

puts "]"