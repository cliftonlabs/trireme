require "trireme/version"
require "yaml"

module Trireme
  @config = {
    devise: {
      model: 'user',
      seed: false
    }
  }

  # @valid_config_keys = @config.keys

  def self.configure(opts = {})
    symbolize_keys(opts).each { |k, v| @config[k] = v } # if @valid_config_keys.include? k.to_sym}
  end

  def self.configure_with(path_to_yaml_file)
    begin
      config = YAML::load(IO.read(path_to_yaml_file))
    rescue Errno::ENOENT
      puts "YAML configuration file couldn't be found. Using defaults."; return
    rescue Psych::SyntaxError
      puts "YAML configuration file contains invalid syntax. Using defaults."; return
    end

    configure(config)
  end

  def self.config
    @config
  end

  def self.symbolize_keys(hash)
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
end
