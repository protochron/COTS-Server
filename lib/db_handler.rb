require 'em-synchrony'
require 'em-synchrony/em-mongo'
#require 'em-mongo'

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
        result = nil
        if collection and @collections[collection]
            result = @collection[collection].find(query)
        else
            result = @queue.find(query)
        end
        result.each{ |doc| doc.delete("_id") }
    end

    # Get a single document from the queue
    def find_one
        result = @queue.first
        result.delete("_id")
    end

    # Insert a document.
    # @return true or false depending on success
    def insert(data, collection=nil)
        result = nil

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
