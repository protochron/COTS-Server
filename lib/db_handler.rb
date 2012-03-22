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
        @found_queue = []
    end

    # Query the message queue for multiple documents
    # This assumes that the collection param comes in as a symbol
    def find(query, collection=nil)
        if collection
            if @collections.has_key collection
                @collections[collection].find(query).defer_as_a.callback do |doc|
                    @found_queue << doc
                end
            end
        else
            @queue.afind({}) do |doc|
            end
        end
        result = @found_queue
        @found_queue = nil
        result
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
