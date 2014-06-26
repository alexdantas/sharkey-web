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

    # Creates a new Link with specified parameters.
    #
    # @note Link#create is a reserved method for DataMapper
    #       it actually inserts it on the database.
    #       This function differs from it on the sense that
    #       it also creates the Tags related to this Link
    #
    # @param tags     String with comma-separated values
    # @param added_at DateTime object or `nil` for DateTime.now
    #
    def self.create_link(title, url, added_at, tags)
      # Silently fail
      return if url.nil?

      # This array will contain the Tags objects
      # created here
      the_tags = []

      tags.split(',').each do |tag|

        # Skipping if got a "string,like,,this,with,,,empty,colons,,,"
        next if tag.nil?

        # If Saruman::Tag exists, return it.
        # Otherwise, create it
        the_tags << Saruman::Tag.first_or_create(name: tag)
      end

      # Actually populating the database with
      # a new Link
      Saruman::Link.create(title:    title || "",
                           url:      url,
                           added_at: added_at || DateTime.now,
                           tags:     the_tags)
      end
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

