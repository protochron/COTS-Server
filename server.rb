require 'json'
require 'yajl'
require 'eventmachine'
require 'em-mongo'

#Not quite sure why this has to be a module, but w/e
module JSONResponder
    @@failed = JSON::generate({:response => 400})
    @@vague_failure= JSON::generate({:response => 500})
    @@success = JSON::generate({:response => 200})

    @parser = nil

    def post_init
        @parser = Yajl::Parser.new(:symbolize_keys => true)
        puts "Client connected."
    end

    def unbind
        puts "Client disconnected."
    end

    def connection_completed
        @parser.on_parse_complete = method(:on_completed)
    end

    #Method to determine what to do with the data
    def receive_data(data)
        #Parse and insert if successful
        #Otherwise do some exception handling using regular HTTP error codes
        begin
            @parser.parse(data)
            send_data @@success
        rescue Yajl::ParseError
            send_data @@failed
        rescue
            send_data @@vague_failure
        end
    end

    private
    #Method for Yajl to specify what to do when a parse is successful
    def on_completed(obj)
        puts "Success!"
        #if obj.class == Hash
        #    @collection.insert(obj)
        #end
    end
end

#Server definition
class COTServer
    attr_accessor :db, :collection

    def initialize(coll_name)
        @name = coll_name
        @db_name = 'cotsbots'
    end


    def run
        #Run EventMachine and connect to Mongo
        EM.run do
            @db = EM::Mongo::Connection.new.db(@db_name)
            @collection = db.collection(@name) #Change this to be user specified
            host = "127.0.0.1"
            port = 8085
            EventMachine::start_server host, port, JSONResponder
            puts "Started server running on #{host}:#{port}"
        end
    end
end

COTServer.new('test_server').run
