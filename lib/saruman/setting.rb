require 'yaml'

module Saruman

  # Global in-app settings.
  #
  # It saves and reads from a YAML file
  module Setting

    # Trying to put it on the root of the app
    SETTING_FILE = File.expand_path('../../../settings.yml', __FILE__)

    module_function

    # Initialize settings with default values
    #
    # @note No need to call this, it's used to guarantee
    #       that the setting file exist.
    def reset
      @values = {
        'loading_bar' => 'true',
        'date_format' => 'relative'
      }
    end

    # Initialize settings with default values THEN
    # loads values from the file.
    #
    # @note Must be called at the beginning of the
    #       program!
    def initialize
      self.reset

      if File.exist? SETTING_FILE
        YAML::load_file SETTING_FILE
      else
        self.save
      end
    end

    # Writes settings into the file
    def save
      File.open(SETTING_FILE, 'w') do |file|
        file.write @values.to_yaml
      end
    end

    # Accesses individual settings, just like a Hash.
    def [] label
      @values[label]
    end

    # Changes individual settings, just like a Hash.
    def []=(label, val)
      @values[label] = val
    end
  end
end

