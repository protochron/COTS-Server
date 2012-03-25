require 'bundler/setup'
require_relative '../lib/cots_server'

#RSpec.configure do |config|
#  # RSpec automatically cleans stuff out of backtraces;
#  # sometimes this is annoying when trying to debug something e.g. a gem
#  config.backtrace_clean_patterns = [
#    /\/lib\d*\/ruby\//,
#    /bin\//,
#    #/gems/,
#    /spec\/spec_helper\.rb/,
#    /lib\/rspec\/(core|expectations|matchers|mocks)/
#  ]
#end


class SampleClient < EventMachine::Connection
    attr_accessor :ondata, :data

    Sample = '{"id":"0.0.0.0","timestamp":"2012-02-08 06:01:43.788"}'
    def initialize
        @data = []
    end

    def receive_data(data)
        @data << data
        @ondata.call if @ondata
    end
    
    def send
        send_data Sample
    end

    def unbind
    end
end

class InsertClient < SampleClient
    Message = '{"insert":{"x":30, "y":40},"id":"0.0.0.0","timestamp":"2012-02-08 06:01:43.788"}'

    def send
        send_data Message
    end
end

class FindClient < SampleClient
    Message = '{"find":{"x":30},"id":"0.0.0.0","timestamp":"2012-02-08 06:01:43.788"}'
    def send
        send_data Message
    end
end

# Begin tests
describe COTServer do 
    configuration = './spec/config.yaml'
    server = COTServer.new(configuration)
    host = '0.0.0.0'
    port = server.directives[:port]

    # Send a basic message to test JSON validation
    it "validates basic JSON" do 
        EventMachine.synchrony do
            EventMachine::start_server host, port, JSONResponder
            $db_handler = DatabaseHandler.new ($options[:database])
            socket = EM.connect('0.0.0.0', server.directives[:port], SampleClient) 
            socket.ondata = -> {
                socket.data.last.chomp.should == JSON.generate(JSONResponder::Success)
                EventMachine.stop
            }
            socket.send
        end
    end

    it "inserts a document" do
        EventMachine.synchrony do
            EventMachine::start_server host, port, JSONResponder
            $db_handler = DatabaseHandler.new ($options[:database])
            socket = EventMachine.connect('0.0.0.0', server.directives[:port], InsertClient) 
            socket.ondata = -> {
                socket.data.last.chomp.should == JSON.generate(JSONResponder::Success)
                EventMachine.stop
            }
            socket.send
            res = $db_handler.find_one
            res.should == {"x" => 30, "y" => 40}
        end
    end

    it "finds a document" do
        EventMachine.synchrony do
            EventMachine::start_server host, port, JSONResponder
            $db_handler = DatabaseHandler.new ($options[:database])
            socket = EventMachine.connect('0.0.0.0', server.directives[:port], FindClient) 
            socket.ondata = -> {
                puts socket.data
                response = Yajl::Parser.parse(socket.data.last, symbolize_keys: true)
                response[:response].should == JSONResponder::Success[:response]
                response[:result].first.should == {x:30, y:40}
                EventMachine.stop
            }
            socket.send
        end
    end
end
