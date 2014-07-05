
require 'sharkey/models'
require 'deps/markio'

module Sharkey

  # Knows how to import from and export to Netscape Bookmark HTML file.
  #
  # This format is commonly used when importing/exporting bookmarks
  # from most browsers and tools such as Delicious.
  #
  # I'm using a modified version of the Ruby Gem Markio
  # (https://github.com/spajus/markio)
  #
  module ImporterExporter
    module_function

    # Imports all Links, their Tags and Categories from a file.
    #
    def import filename

      # TODO Before anything, I should make sure it's a HTML file
      #      and it's not corrupted or anything...

      # Opening and parsing the temporary file, all at once
      bookmarks = File.open(filename) { |file| Markio::parse(file) }

      # Now we go through all of them, creating the Categories and Links
      bookmarks.each do |b|

        # First, we make sure the categories of this Link
        # exist.
        #
        # "Folder" is to "Markio" as "Categories" is to "Sharkey"
        #
        # `b.folders` is an array of category names, like:
        #
        #     ["grandparent", "parent", "child"]
        #
        # So all we need to do is keep creating from the
        # first to the last and the whole category hierarchy
        # will derive.
        #
        last_category        = nil
        last_category_parent = nil

        b.folders.each do |category_name|
          last_category_parent = last_category

          last_category = Sharkey::Category.first_or_create(name: category_name)

          if last_category_parent
#            last_category_parent.add_child last_category
          end
        end

        Sharkey::Link.create_link(b.title,
                                  b.href,
                                  b.add_date,
                                  b.tags,
                                  if   last_category
                                  then if   last_category.id
                                       then last_category.id
                                       else nil
                                       end
                                  else nil
                                  end,
                                  "")
      end

    end

    # Exports
    def export filename
      # Nothing for now
    end
  end
end

