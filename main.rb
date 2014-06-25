require 'sinatra'
require 'slim'
require 'data_mapper'

# For making date/time user-friendly
require 'date'
require 'chronic_duration'

# By default Strings have at max 50 chars of length
# That's hideous! Come on!
DataMapper::Property::String.length 255

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

# This method must be called after ALL models
# have been created and BEFORE the app starts
DataMapper.finalize

begin
  # Full path to the database file
  DATABASE_PATH = "#{Dir.pwd}/tmp/database.db"

  # Starting out the SQLite Database
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{DATABASE_PATH}")

  # Creates Tables if they doesn't exist
  # Tries to adapt new models to already-existing ones...
  DataMapper.auto_upgrade!

  # When the user requests root
  get '/' do

    # Creating an instance variable
    # (visible inside all Views)
    @links = Link.all

    slim :index
  end

  # When the user sends something to root
  post '/' do

    # All tags that will be associated to this Link
    tags = []

    params[:tags].split(',').each do |tag|

      # Skipping if got a "string,like,,this,with,,,missing,colons,,,"
      next if tag.nil?

      # If Tag exists, return it.
      # Otherwise, create it
      tags << Tag.first_or_create(name: tag)
    end

    # The `params` Hash contains everything sent
    # from the URL.
    Link.create(title:    params[:title],
                url:      params[:url],
                added_at: DateTime.now,
                tags:     tags)

    redirect to '/'
  end

  # When the user wants to delete something
  delete '/link/:id' do
    the_link = Link.get(params[:id])

    # Before deleting the link, we must remove
    # all Tag associations
    the_link.taggings.destroy
    the_link.destroy

    redirect to '/'
  end

  # Go to the "Settings page"
  get '/settings' do
    slim :settings
  end

  # Caution!
  delete '/all-links' do
    Tagging.destroy
    Link.destroy

    redirect to '/'
  end

  # Go to the Link page of specific ID
  get '/link/:id' do
    the_link = Link.get(params[:id])
    redirect to '/' if not the_link

    slim(:link, locals: { link: the_link })
  end

  # Go to the Tag page of specific ID
  get '/tag/:id' do
    the_tag = Tag.get(params[:id])
    redirect to '/' if not the_tag

    slim(:tag, locals: { tag: the_tag })
  end
end

