
module Saruman

  # Global in-app settings.
  module Setting
    module_function

    # Initialize settings with default values
    #
    # @note Must be called at the beginning of the
    #       program!
    def initialize
      @values = {
        :loading_bar => true,
        :date_format => 'relative'
      }
    end

    def [] label
      @values[label]
    end

    def []=(label, val)
      @values[label] = val
    end
  end
end

