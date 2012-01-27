require 'bundle/install'
require 'json'
require 'yajl'
require 'eventmachine'
require 'optparser'

#Encapsulates all of the methods for the server
module JSONResponder
    Failed = JSON::generate({:response => 400})
    Vague_failure= JSON::generate({:response => 500})
    Success = JSON::generate({:response => 200})

    def post_init
        @parser = Yajl::Parser.new(:symbolize_keys => true)
        @parser.on_parse_complete = method(:on_completed)
        puts "Client connected."
    end

    def unbind
        puts "Client disconnected."
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
            puts ">>> Failed parsing"
            send_data Failed
        rescue Exception => e
            puts e.message
            puts ">>> Failed parsing"
            send_data Vague_failure
        end
        close_connection_after_writing
    end

    private
    #Method for Yajl to specify what to do when a parse is successful
    def on_completed(obj)
        puts ">>> Successfully parsed JSON."
        puts ">>> Client sent #{obj.inspect}"
        if !obj[:timestamp].nil?
            if obj[:timestamp].match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/)
                send_data Success
                puts ">>> Client got: #{Success}"
            end
        else
            send_data Failed
            puts ">>> Client got: #{Failed}"
        end
    end
end

#Server definition
class COTServer
    attr_accessor :config

    def initialize(config_file)
        @name = coll_name
        @config = config_file
        @directives = Yaml.load(config_file)
    end

    def run
        #Run EventMachine and connect to Mongo
        EM.run do
            host = '0.0.0.0'
            port = 8080
            EventMachine::start_server host, port, JSONResponder
            puts "Started server running on #{host}:#{port}"
        end
    end
end

# Parse cli options
options = {}
parser = OptionParser.new.do |opts|
    opts.banner = ""

    opts.on("-v", "--verbose", "Output full information") do |v|
        options[:verbose] = v 
    end
end.parse!

configuration = ARGV[0]
if configuration.nil?
    puts parser.banner
    exit
end
COTServer.new(configuration).run
