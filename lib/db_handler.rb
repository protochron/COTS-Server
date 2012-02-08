require 'em-mongo'
require 'base64'

# Class to convert server directves into MongoDB commands
class DatabaseHandler

    attr_accessor :db, :collection

    def initialize(coll)
        @db = EM::Mongo::Connection.new('localhost').db('cotsbots')
        @collection = @db.collection(coll)
    end

    def exec(type, query)
        if @collection.respond_to?(type)
            cursor = @collection.method(type)
            resp = cursor.defer_as_a
            
            resp.callback do |docs|
                return docs
            end

            resp.errback do |err|
                $log.log(err, :error)
            end
        end
    end
end
