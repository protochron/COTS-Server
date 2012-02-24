require 'yaml'
require_relative 'jsonresponder'
require_relative 'cotslogger'

#Server definition
class COTServer
    attr_accessor :config, :directives

    # Constructor
    def initialize(config_file)
        @config = config_file
        @directives = symbolize_keys(Psych.load(File.read(config_file)))
        puts @directives.inspect if $options[:verbose]

        #Configure globals
        $options.update(@directives) #update our global options with the contents of the config file 
        $logger = COTSLogger.new($options[:logfile], Logger.class_eval($options[:log_level]), $options[:verbose])
    end

    # Run EventMachine server
    def run
        EM.run do
            host = '0.0.0.0'
            port = @directives[:port]
            EventMachine::start_server host, port, JSONResponder
            $db_handler = DatabaseHandler.new ($options[:database])
            $logger.log("Started server running on #{host}:#{port}", :info)
            puts "Started server running on #{host}:#{port}"
        end
    end
end
