require 'sinatra'
require 'slim'
require 'data_mapper'

# For making date/time user-friendly
require 'date'
require 'chronic_duration'

# To import Links and get page's Titles
require 'nokogiri'

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

# Helper functions that are accessible inside
# every place
helpers do
  def create_link params

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
  end
end

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
    slim(:dashboard_index,
         :layout => :dashboard,
         :locals => { page: "home" })
  end

  # When the user sends something to root
  post '/' do
    create_link params

    redirect to '/'
  end

  # When the user wants to delete a link
  delete '/link/:id' do
    the_link = Link.get(params[:id])

    # Before deleting the link, we must remove
    # all Tag associations
    the_link.taggings.destroy
    the_link.destroy

    redirect back
  end

  # When the user wants to delete a Tag
  delete '/tag/:id' do
    the_tag = Tag.get(params[:id])

    # Before deleting the tag, we must remove
    # all Tag associations
    the_tag.taggings.destroy
    the_tag.destroy

    redirect back
  end

  # Go to the "Settings page"
  get '/settings' do
    slim(:settings_index,
         :layout => :settings,
         :locals => { page: "settings" })
  end

  # Caution!
  delete '/all-links' do
    Tagging.destroy
    Link.destroy
    redirect to '/'
  end
  delete '/all-tags' do
    Tagging.destroy
    Tag.destroy
    redirect to '/'
  end
  delete '/everything' do
    Tagging.destroy
    Link.destroy
    Tag.destroy
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

  # Import Links from Bookmark HTML files
  # (eg. Firefox, Delicious, etc)
  post '/import' do
    unless (params[:file] and params[:file][:tempfile])
      redirect to '/'
    end

    file = File.open(params['file'][:tempfile])
    html = Nokogiri::HTML(file)
    file.close

    html.css('a').each do |link|
      params = {}

      params[:url]   = link.attributes['href'].value
      params[:title] = link.text
      params[:tags]  = link.attributes['tags'].value

      # Support ADDED_AT
      # params[:added_at] = Time.at(link.attributes['add_date'].value.to_i)

      create_link params
    end
    redirect to '/'
  end

  # Add several links at once
  post '/bulk' do

    params[:url].split.each do |url|
      local_params = params

      local_params[:title] = ''
      local_params[:url]   = url
      local_params[:tags]  = params[:tags]

      create_link local_params
    end

    redirect to '/'
  end

  # Show list of all Links
  get '/links' do
    # Creating an instance variable
    # (visible inside all Views)
    @links = Link.all

    slim(:links,
         :layout => :dashboard,
         :locals => { page: "links" })
  end

  # Show list of all Tags
  get '/tags' do
    # Creating an instance variable
    # (visible inside all Views)
    @tags = Tag.all

    slim(:tags,
         :layout => :dashboard,
         :locals => { page: "tags" })
  end

end

