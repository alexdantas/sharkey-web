require 'yaml'

module Sharkey

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
        'date_format' => 'relative',
        'theme'       => 'bootstrap'
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

        # Sometimes on the _development_ environment
        # the settings file gets corrupted...
        # Well, that's a shame!
        begin
          @values = YAML::load_file SETTING_FILE
        rescue
          self.reset
        end

        # Strange error that sometimes appear
        # (@values becomes `false`)
        if not @values.class == Hash
          self.reset
        end
      end
      self.save
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

