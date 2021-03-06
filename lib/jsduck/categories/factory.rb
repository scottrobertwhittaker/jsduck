require 'jsduck/logger'
require 'jsduck/categories/file'
require 'jsduck/categories/auto'
require 'jsduck/categories/class_name'
require 'jsduck/columns'

module JsDuck
  module Categories

    # Reads in categories and outputs them as HTML div
    class Factory
      def self.create(filename, doc_formatter, relations)
        if filename
          categories = Categories::File.new(filename, relations)
        else
          categories = Categories::Auto.new(relations)
        end
        Categories::Factory.new(categories.generate, doc_formatter, relations)
      end

      def initialize(categories, doc_formatter, relations={})
        @categories = categories
        @class_name = Categories::ClassName.new(doc_formatter, relations)
        @columns = Columns.new("classes")
      end

      # Returns HTML listing of classes divided into categories
      def to_html(style="")
        html = @categories.map do |category|
          [
            "<div class='section'>",
            "<h1>#{category['name']}</h1>",
            render_columns(category['groups']),
            "<div style='clear:both'></div>",
            "</div>",
          ]
        end.flatten.join("\n")

        return <<-EOHTML
          <div id='categories-content' style='#{style}'>
            #{html}
          </div>
        EOHTML
      end

      private

      def render_columns(groups)
        align = ["left-column", "middle-column", "right-column"]
        i = -1
        return @columns.split(groups, 3).map do |col|
          i += 1
          [
            "<div class='#{align[i]}'>",
            render_groups(col),
            "</div>",
          ]
        end
      end

      def render_groups(groups)
        return groups.map do |g|
          [
            "<h3>#{g['name']}</h3>",
            "<ul class='links'>",
            g["classes"].map {|cls| "<li>" + @class_name.render(cls) + "</li>" },
            "</ul>",
          ]
        end
      end

    end

  end
end
