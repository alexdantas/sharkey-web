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

  # When the user requests root
  get '/' do

    # Creating an instance variable
    # (visible inside all Views)
    @links = Link.all

    slim :index
  end

  # When the user sends something to root
  post '/' do

    # The `params` Hash contains everything sent
    # from the URL.
    Link.create(title: params[:title], added_at: DateTime.now)

    redirect to '/'
  end

  # When the user wants to delete something
  delete '/link/:id' do
    Link.get(params[:id]).destroy

    redirect to '/'
  end
end

