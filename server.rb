# Gems
require 'bundler/setup'
require_relative './lib/cots_server'

# Parse cli options
parser = OptionParser.new do |opts|
    opts.banner = 'Usage: ruby server.rb [options] <filename>' 

    opts.on("-v", "--verbose", "Output full information") do |v|
        $options[:verbose] = v 
    end

    opts.on("-d" "--[no]drop", "Drop the collection on start") do |d|
        $options[:drop] = d
    end
end
parser.parse!

# Read .yaml configuration file
configuration = ARGV[0]
if configuration.nil?
    puts parser.banner
    exit
end

# Setup and run server
server = COTServer.new(configuration)
server.run
