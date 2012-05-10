###############################################
# Quick script to clear data from the database
###############################################

require 'yaml'
require 'mongo'

file = ARGV.shift
if file.nil?
  puts "Need to supply a config file"
  exit 1
end

config = Psych.load(File.read(file))
db = config["database"]

puts "Warning, this will drop all data stored in the database specified in the config file."
puts "Do you want to continue (y/n)"

while a = gets.chomp
  if a == 'Y' || a == 'y'
    break
  elsif a == 'n' || a == 'N'
    exit 0
  end
end

db = Mongo::Connection.new('localhost').db(db)
db.collections.each do |coll|
  coll.drop if coll.name != 'system.indexes'
end

