# -*- coding: utf-8 -*-
require 'anemone'
require 'nokogiri'
require 'CSV'

urls = ['']

doc = Nokogiri.HTML(open(urls[0]))
str = doc.xpath('//a[@class = "FS2_pager_link_last"]')[0].attribute('href').value

last_page = str.match(/(\d+)\Z/)[1].to_i

# last_page = 1

onlyUrl = false

temp_a = []
temp_a.push(%w(category_url title category category_i_url item_page_url))

folder_name = ''

path = '' + folder_name

FileUtils.mkdir_p(path) unless FileTest.exist?(path)

#
link_match_str = urls[0].match(/(\d+)\Z/)[1]
link_match_str = '' + link_match_str

CSV.open(path + '\\' + 'url.csv', 'w:UTF-8') do |csv|
  csv << temp_a.last

  (1..last_page).each do |temp_i|
    sleep(10) if (temp_i != 1)
    temp_a.clear

    puts temp_i
    # csv << [temp_i.to_s]

    url = urls[0] + '/1/' + temp_i.to_s
    puts url

    doc = Nokogiri.HTML(open(url))
    temp_a.push(urls[0])
    temp_a.push(doc.title)
    temp_a.push(doc.xpath('//p[@class = "pan FS2_breadcrumbs"]').text)

    Anemone.crawl(url, depth_limit: 1, skip_query_strings: true) do |anemone|

      anemone.focus_crawl do |page|
        page.links.keep_if do |link|
          link.to_s.match(/#{link_match_str}/)
        end
      end

      anemone.on_every_page do |page|
        sleep(0.2)
        if onlyUrl
          temp_a.push(page.url.to_s) if page.url.to_s.match(/#{onlyUrl}/)
        else
          temp_a.push(page.url.to_s)
        end

      end
    end

    temp_a.each do |value|
      value.gsub!(/(\r\n|\n|\r)/, '')
    end
    csv << temp_a
  end
end
