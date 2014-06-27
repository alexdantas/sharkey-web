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
      # Nothing for now...
    end

    # When the user wants to navigate to the main page
    get '/' do
      slim(:dashboard_index,
           :layout => :dashboard,
           :locals => { page: "home" })
    end

    # When the user wants to create a single Link
    post '/link' do
      Saruman::Link.create_link(params[:title],
                                params[:url],
                                params[:added_at],
                                params[:tags])
      redirect back
    end

    # When the user wants to delete a link
    delete '/link/:id' do
      the_link = Saruman::Link.get(params[:id])

      # Before deleting the link, we must remove
      # all Saruman::Tag associations
      the_link.taggings.destroy
      the_link.destroy

      # If this is an AJAX request, we don't need
      # to redirect anywhere!
      # The JavaScript is responsible for updating
      # the page, not us!
      redirect back unless request.xhr?
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

      slim(:link,
           :layout => :dashboard,
           locals: { page: "link", link: the_link })
    end

    # Go to the Saruman::Tag page of specific ID
    get '/tag/:id' do
      the_tag = Saruman::Tag.get(params[:id])
      redirect to '/' if not the_tag

      slim(:tag,
           :layout => :dashboard,
           locals: { page: "tag", tag: the_tag })
    end

    # Import Saruman::Links from Bookmark HTML files
    # (eg. Firefox, Delicious, etc)
    #
    # POST requests automatically creates a temporary
    # file for us.
    #
    post '/import' do

      # If we got no temporary file from POST let's just
      # ignore this request
      unless (params[:file] and params[:file][:tempfile])
        redirect back
      end

      # Opening and parsing the temporary file
      # @note Make _sure_ it's a HTML file!
      file = File.open(params['file'][:tempfile])
      html = Nokogiri::HTML(file)
      file.close

      # Getting values from each <a> tag and it's
      # attributes like="this"
      html.css('a').each do |link|

        title    = link.text
        url      = link.attributes['href'].value
        tags     = link.attributes['tags'].value

        # Some links have the date when added (UNIX Timestamp)
        # and others don't
        added_at = if   link.attributes['add_date'].value.empty?
                   then nil
                   else Time.at(link.attributes['add_date'].value.to_i)
                   end

        Saruman::Link.create_link(title,
                                  url,
                                  added_at,
                                  tags)
      end

      # Hooray, everything went out fine!
      redirect to '/'
    end

    # Create several links at once
    post '/links' do

      params[:url].split.each do |url|

        Saruman::Link.create_link(nil,
                                  url,
                                  nil,
                                  params[:tags])
      end

      redirect back
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

