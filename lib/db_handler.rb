require 'em-synchrony'
require 'em-synchrony/em-mongo'
require 'base64'

# Class to convert server directves into MongoDB commands
class DatabaseHandler

    attr_accessor :db, :collections, :queue

    # Constructor
    def initialize(db)
        @db = EM::Mongo::Connection.new('localhost').db(db)
        @queue = @db.collection('message_queue')
        @collections = {}
    end

    # Query the message queue for multiple documents
    # This assumes that the collection param comes in as a symbol
    def find(query, collection=nil)
        cursor = nil

        if collection
            if @collections.has_key? collection
                cursor = @collections[collection].find(query)
            end
        else
            cursor = @queue.find(query)
        end
        cursor
    end

    # Get a single document from the queue
    def find_one
        result = @queue.first
        result.delete("_id")
        result
    end

    # Insert a document.
    # @return true or false depending on success
    def insert(data, collection=nil)
        result = nil

        #if data.has_key? :binary
        #    ext = data[:binary][:ext]
        #    #bin = Base64.urlsafe_decode64(data[:binary][:data])
        #    #File.open("test.#{ext}", 'wb') {|f|
        #    #    f.write(bin)
        #    #}
        #    data.delete(:binary)
        #end

        if collection
            if @collections[collection].nil?
                @collections[collection] = @db.collection(collection.to_s)
            end
            result = @collections[collection].safe_insert(data)
        else
            result = @queue.safe_insert(data)
        end

        result
    end

end # end class
