require 'json'
require 'yajl'
require 'eventmachine'
require 'em-mongo'

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
            message = @parser.parse(data)
            if message[:timestamp].match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/)
                puts ">>> Client sent: #{data}"
                send_data Success
                puts ">>> Client got: #{Success}"
            else
                send_data Failed
                puts ">>> Clinet got: #{Failed}"
            end
            close_connection_after_writing
        rescue Yajl::ParseError
            send_data Failed
        rescue
            send_data Vague_failure
        end
    end

    private
    #Method for Yajl to specify what to do when a parse is successful
    def on_completed(obj)
        puts ">>> Successfully parsed JSON."
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
            host = "0.0.0.0"
            port = 8080
            EventMachine::start_server host, port, JSONResponder
            puts "Started server running on #{host}:#{port}"
        end
    end
end

COTServer.new('test_server').run
