require 'sinatra'
require 'slim'
require 'data_mapper'

# Represents a single HyperLink specified by the user.
#
class Link
  # This tells that it is a thing that will get stored
  # on the database
  # Below are all the database elements
  include DataMapper::Resource

  property :id,          Serial                    # Auto-incrementing key
  property :title,       String, :required => true # User-specified title
  property :added_at,    DateTime                  # When this link was added
end

# This method must be called after ALL models
# have been created and BEFORE the app starts
DataMapper.finalize

begin
  # Starting out the SQLite Database
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

  get '/' do
    slim :index
  end
end

