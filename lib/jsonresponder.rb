require 'json'
require 'yajl'

# Ruby libraries
require 'optparse'
require 'socket'
require_relative 'utilities'
require_relative 'db_handler'

# Global server variables. Not the best design, but there's not a much better way to do it.
$options = {} #hash to contain all options for running the server
$logger = nil
$db_handler = nil

#Encapsulates all of the methods for the server
module JSONResponder
    #Constant hashes for server responses
    Failed = {:response => 400}
    Vague_failure= {:response => 500}
    Success = {:response => 200}

    def post_init
        port, ip = Socket.unpack_sockaddr_in(get_peername)

        @parser = Yajl::Parser.new(:symbolize_keys => true)
        @parser.on_parse_complete = method(:on_completed)
        $logger.log("#{ip} connected on port #{port}", :info)
    end

    def unbind
        $logger.log("Client disconnected", :info)
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
            $logger.log("Failed parsing JSON", :error)
            puts e.backtrace.join("\n")
            send_data JSON::generate(Failed) + "\n"
        rescue Exception => e
            err = e.message + "\n" + e.backtrace.join("\n")
            $logger.log(err, :error)
            send_data JSON::generate(Vague_failure) + "\n"
        end
        #close_connection_after_writing
    end

    private
    #Method for Yajl to specify what to do when a parse is successful
    def on_completed(obj)
        #$logger.log("Client sent #{obj.inspect}", :info)

        if validate_timestamp(obj)
            result = nil

            #Execute specific methods. There's probably a more elegant way to do this...
            if obj.has_key? :find
                flat = to_flat_hash(obj[:find])
                if flat.has_key? :collection
                    collection = flat.delete :collection
                    result = $db_handler.find(flat, collection)
                else
                    result = $db_handler.find(flat)
                end
            elsif obj.has_key? :find_one
                result = $db_handler.find_one
            elsif obj.has_key? :insert
                if obj[:insert].has_key? :collection
                    collection = obj[:insert].delete :collection # this returns the value
                    $db_handler.insert(obj[:insert], collection)
                else
                    $db_handler.insert(obj[:insert])
                end
            end

            # Construct and send a response
            response = Success
            response[:result] = result if !result.nil?
            send_data JSON::generate(response) + "\n"
            $logger.log("Client got: #{response}", :info)
        else
            send_data JSON::generate(Failed) + "\n"
            $logger.log("Client got: #{Failed}", :info)
        end
    end
end
