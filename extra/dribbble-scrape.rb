require 'rubygems'
require 'nokogiri'
require 'open-uri'

results = []

(1..2).each do |current|

    scrape_page = "http://dribbble.com/designers?page=#{current}"

    page = Nokogiri::HTML(open(scrape_page))

    links = page.css('.url')

    links.each do |link|
      username = link['href'][1..-1]
      puts username
      results << "#{username}"
    end

    sleep 5

end


puts "******"
puts results.to_s