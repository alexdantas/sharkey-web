# Application file for Saruman
#
# Here we define the actions that Sinatra needs to take (routes)

require 'sinatra'
require 'slim'
require 'data_mapper'

# For making date/time user-friendly
require 'date'
require 'chronic_duration'

# To import Saruman::Links and get page's Titles
require 'nokogiri'

# Create and initialize the databases
require 'saruman/models'

module Saruman
  class App < Sinatra::Application

    # Helper functions that are accessible inside
    # every place
    helpers do
      def create_link params

        # All tags that will be associated to this Saruman::Link
        tags = []

        params[:tags].split(',').each do |tag|

          # Skipping if got a "string,like,,this,with,,,missing,colons,,,"
          next if tag.nil?

          # If Saruman::Tag exists, return it.
          # Otherwise, create it
          tags << Saruman::Tag.first_or_create(name: tag)
        end

        # The `params` Hash contains everything sent
        # from the URL.
        Saruman::Link.create(title:    params[:title],
                             url:      params[:url],
                             added_at: DateTime.now,
                             tags:     tags)
      end
    end

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
      the_link = Saruman::Link.get(params[:id])

      # Before deleting the link, we must remove
      # all Saruman::Tag associations
      the_link.taggings.destroy
      the_link.destroy

      redirect back
    end

    # When the user wants to delete a Saruman::Tag
    delete '/tag/:id' do
      the_tag = Saruman::Tag.get(params[:id])

      # Before deleting the tag, we must remove
      # all Saruman::Tag associations
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
      Saruman::Tagging.destroy
      Saruman::Link.destroy
      redirect to '/'
    end
    delete '/all-tags' do
      Saruman::Tagging.destroy
      Saruman::Tag.destroy
      redirect to '/'
    end
    delete '/everything' do
      Saruman::Tagging.destroy
      Saruman::Link.destroy
      Saruman::Tag.destroy
      redirect to '/'
    end

    # Go to the Saruman::Link page of specific ID
    get '/link/:id' do
      the_link = Saruman::Link.get(params[:id])
      redirect to '/' if not the_link

      slim(:link, locals: { link: the_link })
    end

    # Go to the Saruman::Tag page of specific ID
    get '/tag/:id' do
      the_tag = Saruman::Tag.get(params[:id])
      redirect to '/' if not the_tag

      slim(:tag, locals: { tag: the_tag })
    end

    # Import Saruman::Links from Bookmark HTML files
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

    # Show list of all Saruman::Links
    get '/links' do
      # Creating an instance variable
      # (visible inside all Views)
      @links = Saruman::Link.all

      slim(:links,
           :layout => :dashboard,
           :locals => { page: "links" })
    end

    # Show list of all Saruman::Tags
    get '/tags' do
      # Creating an instance variable
      # (visible inside all Views)
      @tags = Saruman::Tag.all

      slim(:tags,
           :layout => :dashboard,
           :locals => { page: "tags" })
    end

    not_found do
      slim(:'404', :locals => { url: request.fullpath })
    end
  end
end

