require 'em-mongo'
require_relative '../lib/cots_server'

class SampleClient < EventMachine::Connection
    attr_accessor :ondata, :data

    Sample = '{"id":"0.0.0.0","timestamp":"2012-02-08 06:01:43.788"}'
    def initialize
        @data = []
        send_data Sample
    end

    def receive_data(data)
        @data << data
        @ondata.call if @ondata
    end

    def unbind
    end
end

# Begin tests
describe COTServer do 
    it "validates basic JSON" do 
        configuration = './spec/config.yaml'
        server = COTServer.new(configuration)
        EM.run do
            host = '0.0.0.0'
            port = server.directives[:port]
            EventMachine::start_server host, port, JSONResponder
            $db_handler = DatabaseHandler.new ($options[:database])
            socket = EM.connect('0.0.0.0', server.directives[:port], SampleClient) 
            socket.ondata = -> {
                socket.data.last.chomp.should == JSON.generate(JSONResponder::Success)
                EM.stop
            }
        end
    end
end
