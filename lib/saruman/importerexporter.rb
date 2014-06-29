
require 'saruman/models'

module Saruman
  # Knows how to import from and export to Netscape Bookmark HTML file.
  #
  # This format is commonly used when importing/exporting bookmarks
  # from most browsers and tools such as Delicious.
  #
  module ImporterExporter
    module_function

    # Imports
    def import filename
      # @note Before anything, make _sure_ it's a HTML file!

      # Opening and parsing the temporary file
      file = File.open(filename)
      html = Nokogiri::HTML(file)
      file.close

      # Getting values from each <a> tag and it's
      # attributes like="this"
      html.css('a').each do |link|

        title = link.text
        url   = link.attributes['href'].value
        tags  = if   link.attributes['tags']
                then link.attributes['tags'].value
                else ""
                end

        # Some links have the date when added (UNIX Timestamp)
        # and others don't
        added_at = if   link.attributes['add_date']
                   then Time.at(link.attributes['add_date'].value.to_i)
                   else nil
                   end

        Saruman::Link.create_link(title,
                                  url,
                                  added_at,
                                  tags,
                                  nil)
      end

    end

    # Exports
    def export filename
      # Nothing for now
    end
  end
end

