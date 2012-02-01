require 'logger'

# Create multiple Logger instances to print to stdout and/or a logfile
class COTSLogger
    attr_accessor :log, :stdout
    def initialize(file, severity, verbose)
        @log = Logger.new(file)
        @log.level = severity
        puts "Created log with #{file}"
        
        if verbose
            @stdout = Logger.new(STDOUT)
        end
    end

    def log(text, severity)
        if @log.respond_to?(severity)
            @log.send severity, text
            if !@stdout.nil?
                @stdout.send severity, text
            end
        end
    end
end
