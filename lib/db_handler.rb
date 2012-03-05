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
        result = []

        if collection
            if @collections.has_key? collection
                cursor = @collections[collection].find(query)
            else
                return result
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
        cursor = nil
        if collection
            if @collections[collection].nil?
                @collections[collection] = @db.collection(collection.to_s)
            end
            cursor = @collections[collection].safe_insert(data)
        else
            cursor = @queue.safe_insert(data)
        end

        result = true 

        #Callback when query is successful
        #cursor.callback do |doc|
        #    result = true 
        #end

        #Log any error
        cursor.errback do |err|
            $log.log(err, :error)
            result = false
        end

        result
    end

end # end class
