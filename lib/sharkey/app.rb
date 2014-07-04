# Application file for Sharkey
#
# Here we define the actions that Sinatra needs to take (routes)

require 'sinatra'
require 'slim'
require 'data_mapper'

# For making date/time user-friendly
require 'date'
require 'chronic_duration'

# To import Sharkey::Links and get page's Titles
require 'nokogiri'

# Create and initialize the databases
require 'sharkey/models'

require 'sharkey/setting'
require 'sharkey/importerexporter'

require 'json'

module Sharkey
  class App < Sinatra::Application

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # Initializing the server

    # Global in-app settings
    # (not related to Sinatra per se)
    Sharkey::Setting.initialize

    # Helper functions that are accessible inside
    # every place
    helpers do
      def delete_link id
        link = Sharkey::Link.get id
        return if not link

        # Before deleting the link, we must remove
        # all Sharkey::Tag associations
        link.taggings.destroy       if link.taggings
        link.categorization.destroy if link.categorization

        link.reload
        link.destroy
      end

      def delete_tag id
        tag = Sharkey::Tag.get id
        return if not tag

        tag.taggings.destroy if tag.taggings

        tag.reload
        tag.destroy
      end

      def delete_category id
        category = Sharkey::Category.get id
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

      def random_sentence
        @sentences ||= File.readlines(File.join(File.dirname(__FILE__), '/public/data/sentences.txt'))
        @sentences.sample
      end

      # Converts `datetime` object into a relative date String
      # (like "2 days, 8 hours, 15 minutes, 2 seconds")
      def relative_date datetime
        return '' if datetime.nil?

        # Now we'll calculate a short, human-friendly
        # version of the full date (like '2 days, 5 hours')
        added_secs = datetime.strftime('%s').to_i
        now_secs   = DateTime.now.strftime('%s').to_i

        ChronicDuration.output(now_secs - added_secs)
      end

      # Converts `datetime` object into a formatted date String
      # suited for HTML5's <time datetime=""> attributes!
      def formatted_date datetime
        return '' if datetime.nil?

        datetime.strftime '%Y-%m-%d %H:%m'
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
        links = Sharkey::Link.by_tag(params[:id])

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
        links = Sharkey::Link.by_category(params[:id])

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
      Sharkey::Tagging.destroy
      Sharkey::Link.destroy
      redirect to '/'
    end

    delete '/all-tags' do
      Sharkey::Tagging.destroy
      Sharkey::Tag.destroy
      redirect to '/'
    end

    delete '/all-categories' do
      Sharkey::Categorization.destroy
      Sharkey::CategoryParent.destroy
      Sharkey::CategoryChild.destroy
      Sharkey::Category.destroy
      redirect to '/'
    end

    delete '/everything' do
      Sharkey::Tagging.destroy
      Sharkey::Link.destroy
      Sharkey::Tag.destroy
      Sharkey::Categorization.destroy
      Sharkey::CategoryParent.destroy
      Sharkey::CategoryChild.destroy
      Sharkey::Category.destroy
      redirect to '/'
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # Individual pages
    get '/link/:id' do
      the_link = Sharkey::Link.get(params[:id])
      redirect to '/' if not the_link

      slim(:link,
           :layout => :dashboard,
           locals: { page: "link", link: the_link })
    end

    get '/tag/:id' do
      the_tag = Sharkey::Tag.get(params[:id])
      redirect to '/' if not the_tag

      slim(:tag,
           :layout => :dashboard,
           locals: { page: "tag", tag: the_tag })
    end

    get '/category/:id' do
      the_category = Sharkey::Category.get(params[:id])
      redirect to '/' if not the_category

      slim(:category,
           :layout => :dashboard,
           locals: { page: "category", category: the_category })
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # Creating things

    post '/link' do
      Sharkey::Link.create_link(params[:title],
                                params[:url],
                                params[:added_at],
                                params[:tags],
                                params[:category],
                                params[:comment])

      # If AJAX request, don't redirect anywhere!
      redirect back unless request.xhr?
    end

    post '/links' do

      params[:url].split.each do |url|

        Sharkey::Link.create_link(nil,
                                  url,
                                  nil,
                                  params[:tags] || [],
                                  params[:category],
                                  "")
      end
      redirect back unless request.xhr?
    end

    post '/category' do
      new_category = Sharkey::Category.first_or_create(name: params[:name]);

      parent_category = Sharkey::Category.get(params[:parent])
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
    # Updating things
    #
    # Unfortunately I couldn't use the PUT method - even when
    # adding a hidden '<input>' and all that crap.
    # It ain't the order of Sinatra routes also... So I fell
    # back to good old POST with different URL.

    post '/update/link/:id' do
      return 404 if not params[:id]

      Sharkey::Link.update_link(params[:id],
                                params[:title],
                                params[:url],
                                params[:tags],
                                params[:category],
                                params[:comment])

      # If AJAX request, don't redirect anywhere!
      redirect back unless request.xhr?
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # Pages that list things

    get '/links' do
      # Creating an instance variable
      # (visible inside all Views)
      @links = Sharkey::Link.all

      slim(:links,
           :layout => :dashboard,
           :locals => { page: "links" })
    end

    get '/tags' do
      # Creating an instance variable
      # (visible inside all Views)
      @tags = Sharkey::Tag.all

      # MagicSuggest, the jQuery plugin, uses this to give
      # suggestions on Tag input fields.
      #
      # If request is AJAX, return a JSON
      # array with all existing tags
      if request.xhr?
        return @tags.sort.to_json
      end

      # Now, the user can send other values to
      # specify how they will get sorted
      case params[:sort]
      when 'name'
        @tags = @tags.sort_by { |t| t.name }

      when 'count'
        @tags = @tags.sort_by { |t| t.taggings.count } .reverse

      when 'id'
        @tags = @tags.sort_by { |t| t.id }
      end

      slim(:tags,
           :layout => :dashboard,
           :locals => { page: "tags" })
    end

    get '/categories' do

      # Let's start by showing all Categories
      # WITHOUT parents.
      # Then, recursively show their children
      @categories = Sharkey::Category.orphans

      # Now, the user can send other values to
      # specify how they will get sorted
      case params[:sort]
      when 'name'
        @categories = @categories.sort_by { |t| t.name }

      when 'count'
        @categories = @categories.sort_by { |t| t.categorizations.count } .reverse

      when 'id'
        @categories = @categories.sort_by { |t| t.id }
      end

      slim(:categories,
           :layout => :dashboard,
           :locals => { page: "categories" })
    end

    get '/favorites' do
      @links = Sharkey::Link.all(favorite: true)

      slim(:links,
           :layout => :dashboard,
           :locals => { page: "favorites" })
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
        Sharkey::Setting['theme'] = params[:theme]
        Sharkey::Setting.save
        redirect back
      end

      # Error for non-existing setting
      return 500 unless Sharkey::Setting[params[:name]]
      return 500 unless params[:value]

      Sharkey::Setting[params[:name]] = params[:value]
      Sharkey::Setting.save

      if request.xhr?
        return 200
      else
        redirect back
      end
    end

    # Import Sharkey::Links from Bookmark HTML files
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
      @tags = Sharkey::Tag.all

      slim(:tagcloud,
           :layout => :dashboard,
           :locals => { page: "tagcloud" })
    end

    # Surprise me!
    get '/random' do
      the_link = Sharkey::Link.all.sample

      slim(:link,
           :layout => :dashboard,
           locals: { page: "link", link: the_link })
    end

    # Toggles the favorite state of the Link with :id
    #
    # Returns the item's favorite state _after_ the change.
    post '/favorite/:id' do
      the_link = Sharkey::Link.get params[:id]
      return 502 if not the_link

      the_link.toggle_favorite
      return "{ \"isFavorite\": #{the_link.favorite} }"
    end

    # Increase the visit count of a link
    post '/visit/:id' do
      the_link = Sharkey::Link.get params[:id]
      return 502 if not the_link

      the_link.visit
      return "{ \"visitCount\": #{the_link.visit_count} }"
    end

    get '/help' do
      slim(:help,
           :layout => :centered,
           locals: { page: "help" })
    end

    get '/about' do
      slim(:about,
           :layout => :centered,
           locals: { page: "about" })
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # Error-handling

    not_found do
      slim(:'404', :locals => { url: request.fullpath })
    end
  end
end

