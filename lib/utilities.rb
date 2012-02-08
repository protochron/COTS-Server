# Convert hash keys from string to symbol
def symbolize_keys(hash)
    hash.inject({}){|result, (key, value)|
        new_key = case key
                  when String then key.to_sym
                  else key
                  end
        new_value = case value
                    when Hash then symbolize_keys(value)
                    else value
                    end
        result[new_key] = new_value
        result
    }
end

# Pattern-match a timestamp in default Android format
def validate_timestamp(obj)
    if !obj[:timestamp].nil?
        if obj[:timestamp].match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.\d{3}/)
            return true
        end
    end
    false
end
