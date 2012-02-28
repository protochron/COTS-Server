require 'em-mongo'
require 'base64'

# Class to convert server directves into MongoDB commands
class DatabaseHandler

    attr_accessor :db, :collections, :queue

    # Constructor
    def initialize(db)
        @db = EM::Mongo::Connection.new('localhost').db(db)
        #@collection = @db.collection(coll)
        @queue = @db.collection('message_queue')
        @collections = {}
    end

    # Query the message queue for multiple documents
    # This assumes that the collection param comes in as a symbol
    def find(query, collection=nil)
        cursor = nil
        if collection
            if @collections.has_key? collection
                cursor = @collections[collection]
            else
                return [] 
            end
        else
            cursor = @queue.find
        end
        resp = cursor.defer_as_a
        result = []

        #Callback when query is successful
        resp.callback do |docs|
            $log.log("Found #{docs.length} results", :info)
        end

        # Log any error
        resp.errback do |err|
            $log.log(err, :error)
        end

        if collection
            @collections[collection].find(query).each do |doc|
                result << doc if doc
            end
        else
            @queue.find(query).each do |doc|
                result << doc if doc
            end
        end

        result
    end

    # Get a single document from the queue
    def find_one
        cursor = @queue.find_one
        result = []

        #Callback when query is successful
        cursor.callback do |docs|
            result << docs if docs
        end

        #Log any error
        cursor.errback do |err|
            $log.log(err, :error)
        end

        #@queue.find_one.each do |doc|
        #    result << doc if doc
        #end
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
        cursor.callback do |docs|
            result = true
        end

        #Log any error
        cursor.errback do |err|
            $log.log(err, :error)
            result = false
        end

        result
    end


end # end class
