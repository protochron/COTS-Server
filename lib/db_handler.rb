require 'em-mongo'
require 'base64'

# Class to convert server directves into MongoDB commands
class DatabaseHandler

    attr_accessor :db, :collection

    # Constructor
    def initialize(coll)
        @db = EM::Mongo::Connection.new('localhost').db('cotsbots')
        @collection = @db.collection(coll)
    end

    # Query the database for multiple documents
    def find(query)
        cursor = @collection.find
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

        @collection.find(query).each do |doc|
            result << doc if doc
        end

        result
    end

    # Get a single document
    def find_one
        cursor = @collection.find_one
        resp = cursor.defer_as_a
        result = []

        #Callback when query is successful
        resp.callback do |docs|
            $log.log("Found #{docs.length} results", :info)
        end

        #Log any error
        resp.errback do |err|
            $log.log(err, :error)
        end

        @collection.find_one.each do |doc|
            result << doc if doc
        end
        result
    end

    # Insert a document.
    # @return true or flass depending on success
    def insert(data)
        cursor = @collection.safe_insert(data)
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

end
