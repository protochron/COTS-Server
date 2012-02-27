require 'em-mongo'
require_relative '../lib/cots_server'

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

# Begin tests
describe COTServer do 
    configuration = './spec/config.yaml'
    server = COTServer.new(configuration)
    host = '0.0.0.0'
    port = server.directives[:port]

    it "validates basic JSON" do 
        EM.run do
            EventMachine::start_server host, port, JSONResponder
            $db_handler = DatabaseHandler.new ($options[:database])
            socket = EM.connect('0.0.0.0', server.directives[:port], SampleClient) 
            socket.ondata = -> {
                socket.data.last.chomp.should == JSON.generate(JSONResponder::Success)
                EM.stop
            }
            socket.send
        end
    end
end
