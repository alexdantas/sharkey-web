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

require 'json'

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
      def delete_link id
        link = Saruman::Link.get id
        return if not link

        # Before deleting the link, we must remove
        # all Saruman::Tag associations
        link.taggings.destroy       if link.taggings
        link.categorization.destroy if link.categorization

        link.reload
        link.destroy
      end

      def delete_tag id
        tag = Saruman::Tag.get id
        return if not tag

        tag.taggings.destroy if tag.taggings

        tag.reload
        tag.destroy
      end

      def delete_category id
        category = Saruman::Category.get id
        return if not category

        # * `category.parent` is a pointer to
        #   another Category
        # * `category.categoryParent` is a pointer
        #   to the RELATIONSHIP to another Category

        # Removing ties to other Categories...
        if category.parent
          category.parent.remove_child category
        end
        if category.categoryParent
          category.categoryParent.destroy
        end

        if not category.childs.empty?
          category.childs.each { |child| category.remove_child(child) }
        end

        # ...and to other Links...
        if category.categorizations
          category.categorizations.destroy
        end

        # ...and finally to itself
        category.reload
        category.destroy
      end

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
      delete_link(params[:id])

      # If this is an AJAX request, we don't need
      # to redirect anywhere!
      # The JavaScript is responsible for updating
      # the page, not us!
      redirect back unless request.xhr?
    end

    # Extra parameters:
    #
    # - destroy_links If should also destroy links with this tag
    #
    delete '/tag/:id' do

      # Welp, here we go!
      # Send a DELETE request for each link
      if (params[:destroy_links])
        links = Saruman::Link.by_tag(params[:id])

        links.each { |link| delete_link link.id }
      end

      delete_tag params[:id]

      # If this is an AJAX request, we don't need
      # to redirect anywhere!
      # The JavaScript is responsible for updating
      # the page, not us!
      redirect back unless request.xhr?
    end

    # Extra parameters:
    #
    # - destroy_links If should also destroy links with this category
    #
    delete '/category/:id' do

      # Welp, here we go!
      # Send a DELETE request for each link
      if (params[:destroy_links])
        links = Saruman::Link.by_category(params[:id])

        links.each { |link| delete_link link.id }
      end

      delete_category params[:id]

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
      Saruman::CategoryParent.destroy
      Saruman::CategoryChild.destroy
      Saruman::Category.destroy
      redirect to '/'
    end

    delete '/everything' do
      Saruman::Tagging.destroy
      Saruman::Link.destroy
      Saruman::Tag.destroy
      Saruman::Categorization.destroy
      Saruman::CategoryParent.destroy
      Saruman::CategoryChild.destroy
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

      # If AJAX request, don't redirect anywhere!
      redirect back unless request.xhr?
    end

    post '/links' do

      params[:url].split.each do |url|

        Saruman::Link.create_link(nil,
                                  url,
                                  nil,
                                  params[:tags] || [],
                                  params[:category])
      end
      redirect back unless request.xhr?
    end

    post '/category' do
      new_category = Saruman::Category.first_or_create(name: params[:name]);

      parent_category = Saruman::Category.get(params[:parent])
      # Silently fail if invalid ID was given
      if (parent_category)
        parent_category.add_child(new_category)
      end

      # If this is an AJAX request, we'll return a JSON
      # string with information on the recently-added Category
      if request.xhr?
        return "{ \"id\": \"#{new_category.id}\", \"name\": \"#{new_category.name}\" }"
      else
        redirect back
      end
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
      @tags = Saruman::Tag.all.sort

      # MagicSuggest, the jQuery plugin, uses this to give
      # suggestions on Tag input fields.
      #
      # If request is AJAX, return a JSON
      # array with all existing tags
      if request.xhr?
        return @tags.to_json
      end

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

    post '/debug' do
      slim("#{params.inspect}")
    end

    post '/setting' do
      # HACK
      # BIG EXCEPTION are <select> elements, who fuck up
      # the entire standard
      if (params[:theme])
        Saruman::Setting['theme'] = params[:theme]
        Saruman::Setting.save
        redirect back
      end

      # Error for non-existing setting
      return 500 unless Saruman::Setting[params[:name]]
      return 500 unless params[:value]

      Saruman::Setting[params[:name]] = params[:value]
      Saruman::Setting.save

      if request.xhr?
        return 200
      else
        redirect back
      end
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

    get '/tagcloud' do
      @tags = Saruman::Tag.all

      slim(:tagcloud,
           :layout => :dashboard,
           :locals => { page: "tagcloud" })
    end

    # Surprise me!
    get '/random' do
      the_link = Saruman::Link.all.sample

      slim(:link,
           :layout => :dashboard,
           locals: { page: "link", link: the_link })
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # Error-handling

    not_found do
      slim(:'404', :locals => { url: request.fullpath })
    end
  end
end

