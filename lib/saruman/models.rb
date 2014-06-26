# This file contains all Models (database-thingies) of this
# Application.
#
# We're using DataMapper as the interface to raw SQLite
# databases.
#
# So here's what we do on this file:
#
# 1. Initialize DataMapper (settings 'n stuff)
# 2. Define the Models
#    Specify things and columns in databases
# 3. Finalize DataMapper (_actually_ create the tables)
#

require 'data_mapper'

module Saruman

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  # Initializing DataMapper

  # Full path to the database file
  DATABASE_PATH = "sqlite3://#{Dir.pwd}/database.db"

  # By default Strings have at max 50 chars of length
  # That's hideous! Come on!
  DataMapper::Property::String.length 255

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  # Creating Models

  # Represents a single HyperLink specified by the user.
  #
  class Link
    # This tells that it is a thing that will get stored
    # on the database
    # Below are all the database elements
    include DataMapper::Resource

    property :id,       Serial                    # Auto-incremented key
    property :url,      String, :required => true # Actual URL
    property :title,    String                    # User-specified title
    property :added_at, DateTime                  # When this link was added

    has n, :taggings
    has n, :tags, :through => :taggings
  end

  # Single textual tag Links can have
  #
  class Tag
    include DataMapper::Resource

    property :id,   Serial
    property :name, String, :required => true

    has n, :taggings
    has n, :links, :through => :taggings
  end

  # The actual action of tagging Links.
  #
  # This is necessary because we can query both
  # of them:
  # - All Links of a Tag
  # - All Tags of a Link
  #
  class Tagging
    include DataMapper::Resource

    belongs_to :tag,  :key => true
    belongs_to :link, :key => true
  end

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  # Create Tables

  # This method must be called after ALL models
  # have been created and BEFORE the app starts
  DataMapper.finalize

  # Starting out the SQLite Database
  DataMapper.setup(:default,
                   ENV['DATABASE_URL'] || DATABASE_PATH)

  # Creates Tables if they doesn't exist
  # Tries to adapt new models to already-existing ones...
  DataMapper.auto_upgrade!
end

