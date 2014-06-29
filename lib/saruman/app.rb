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

require 'saruman/setting'
require 'saruman/importerexporter'

module Saruman
  class App < Sinatra::Application

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # Initializing the server

    # Global in-app settings
    # (not related to Sinatra per se)
    Saruman::Setting.initialize

    # Helper functions that are accessible inside
    # every place
    helpers do
      # Nothing for now...
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # Standalone pages

    get '/' do
      slim(:dashboard_index,
           :layout => :dashboard,
           :locals => { page: "home" })
    end

    get '/settings' do
      slim(:settings_index,
           :layout => :settings,
           :locals => { page: "settings" })
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # Deleting stuff

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

    delete '/tag/:id' do
      the_tag = Saruman::Tag.get(params[:id])

      # Before deleting the tag, we must remove
      # all Saruman::Tag associations
      the_tag.taggings.destroy
      the_tag.destroy

      # If this is an AJAX request, we don't need
      # to redirect anywhere!
      # The JavaScript is responsible for updating
      # the page, not us!
      redirect back unless request.xhr?
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # Deleting too much stuff (Caution!)

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

    delete '/all-categories' do
      Saruman::Categorization.destroy
      Saruman::Category.destroy
      redirect to '/'
    end

    delete '/everything' do
      Saruman::Tagging.destroy
      Saruman::Link.destroy
      Saruman::Tag.destroy
      Saruman::Categorization.destroy
      Saruman::Category.destroy
      redirect to '/'
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # Individual pages

    get '/link/:id' do
      the_link = Saruman::Link.get(params[:id])
      redirect to '/' if not the_link

      slim(:link,
           :layout => :dashboard,
           locals: { page: "link", link: the_link })
    end

    get '/tag/:id' do
      the_tag = Saruman::Tag.get(params[:id])
      redirect to '/' if not the_tag

      slim(:tag,
           :layout => :dashboard,
           locals: { page: "tag", tag: the_tag })
    end

    get '/category/:id' do
      the_category = Saruman::Category.get(params[:id])
      redirect to '/' if not the_category

      slim(:category,
           :layout => :dashboard,
           locals: { page: "category", category: the_category })
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # Creating things

    post '/link' do
      Saruman::Link.create_link(params[:title],
                                params[:url],
                                params[:added_at],
                                params[:tags],
                                params[:category])
      redirect back
    end

    post '/links' do

      params[:url].split.each do |url|

        Saruman::Link.create_link(nil,
                                  url,
                                  nil,
                                  params[:tags],
                                  params[:category])
      end

      redirect back
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # Pages that list things

    get '/links' do
      # Creating an instance variable
      # (visible inside all Views)
      @links = Saruman::Link.all

      slim(:links,
           :layout => :dashboard,
           :locals => { page: "links" })
    end

    get '/tags' do
      # Creating an instance variable
      # (visible inside all Views)
      @tags = Saruman::Tag.all

      slim(:tags,
           :layout => :dashboard,
           :locals => { page: "tags" })
    end

    get '/categories' do

      # Let's start by showing all Categories
      # WITHOUT parents.
      # Then, recursively show their children
      @categories = Saruman::Category.orphans

      slim(:categories,
           :layout => :dashboard,
           :locals => { page: "categories" })
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # Misc. pages

    post '/setting' do
      # Error for non-existing setting
      return 500 unless Saruman::Setting[params[:name]]
      return 500 unless params[:value]

      Saruman::Setting[params[:name]] = params[:value]
      Saruman::Setting.save
      200
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

      ImporterExporter::import params['file'][:tempfile]
      redirect to '/'
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # Error-handling

    not_found do
      slim(:'404', :locals => { url: request.fullpath })
    end
  end
end

