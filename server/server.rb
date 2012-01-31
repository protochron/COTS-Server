# Gems
require 'bundler/setup'
require 'json'
require 'yajl'
require 'eventmachine'

# Ruby libraries
require 'optparse'
require 'socket'
require 'date'
require_relative './lib/utilities'

$options = {} #hash to contain all options for running the server

#Encapsulates all of the methods for the server
module JSONResponder
    Failed = JSON::generate({:response => 400})
    Vague_failure= JSON::generate({:response => 500})
    Success = JSON::generate({:response => 200})

    def post_init
        port, ip = Socket.unpack_sockaddr_in(get_peername)

        @parser = Yajl::Parser.new(:symbolize_keys => true)
        @parser.on_parse_complete = method(:on_completed)
        puts ">>> #{ip} connected." if $options[:verbose]

        if $options[:logfile]
            $options[:fh].puts "#{Time.now}: #{ip} connected"
        end
    end

    def unbind
        puts "Client disconnected." if $options[:verbose]

        if $options[:logfile]
            $options[:fh].puts "#{Time.now}: Client disconnected"
        end
    end

    def connection_completed
    end

    #Method to determine what to do with the data
    def receive_data(data)
        #Parse and insert if successful
        #Otherwise do some exception handling using regular HTTP error codes
        begin
            @parser.parse(data)
        rescue Yajl::ParseError
            puts ">>> Failed parsing" if $options[:verbose]
            if $options[:logfile]
                $options[:fh].puts "#{Time.now}: Failed parsing JSON"            
            end
            send_data Failed
        rescue Exception => e
            if $options[:verbose]
                puts e.message
                puts ">>> Failed parsing"
            end

            if $options[:logfile]
                $options[:fh].puts "#{Time.now}: #{e.message}"
            end
            send_data Vague_failure
        end
        close_connection_after_writing
    end

    private
    #Method for Yajl to specify what to do when a parse is successful
    def on_completed(obj)
        puts ">>> Client sent #{obj.inspect}" if $options[:verbose]
        if $options[:logfile]
            $options[:fh].puts "#{Time.now}: Client sent #{obj.inspect}"
        end

        if validate_timestamp(obj)
            send_data Success
            puts ">>> Client got: #{Success}" if $options[:verbose]
            if $options[:logfile]
                $options[:fh].puts "#{Time.now}: Client got: #{Success}"
            end
        else
            send_data Failed
            puts ">>> Client got: #{Failed}" if $options[:verbose]
            if $options[:logfile]
                $options[:fh].puts "#{Time.now}: Client got: #{Failed}" 
            end
        end

    end

    # Pattern-match a timestamp in default Android format
    def validate_timestamp(obj)
        if !obj[:timestamp].nil?
            if obj[:timestamp].match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.\d{3}/)
                return true
            end
        end
        false
    end
end

#Server definition
class COTServer
    attr_accessor :config, :directives

    def initialize(config_file)
        @config = config_file
        @directives = symbolize_keys(Psych.load(File.read(config_file)))
        puts @directives.inspect if $options[:verbose]

        if @directives[:logfile]
            @directives[:fh] = File.open(@directives[:logfile], 'a')
        end

        $options.update(@directives) #update our global options with the contents of the config file 
    end

    # Run EventMachine server
    def run
        EM.run do
            host = '0.0.0.0'
            port = @directives[:port]
            EventMachine::start_server host, port, JSONResponder
            puts "Started server running on #{host}:#{port}"
        end
    end
end

# Parse cli options
parser = OptionParser.new do |opts|
    opts.banner = 'Usage: ruby server.rb [options] <filename>' 

    opts.on("-v", "--verbose", "Output full information") do |v|
        $options[:verbose] = v 
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
server.directives[:required_libs].each do |lib|
    puts ">>> Loading #{lib} gem" if $options[:verbose]
    require lib 
end
server.run
