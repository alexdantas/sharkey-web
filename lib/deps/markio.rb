require "deps/markio/version"
require "deps/markio/bookmark"
require "deps/markio/parser"
require "deps/markio/builder"
module Markio
  def self.parse(data)
    Parser.new(data).parse
  end
end
