require 'active_support/core_ext/integer/inflections'

module Jekyll
  module MoreFilters
    def meetup_title(meetup)
      number = meetup["number"].to_s.rjust(3, "0")
      title  = meetup["title"]
      "<span class='number'>#{number}</span> - <span class='title'>#{title}</span>"
    end

    def nice_date(date)
      if date
        ordinal = ActiveSupport::Inflector.ordinal(date.day)
        date.strftime("#{date.day}<sup>#{ordinal}</sup> %B %Y")
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::MoreFilters)
