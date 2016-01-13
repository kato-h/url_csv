# -*- coding: utf-8 -*-
require 'capybara'
require 'capybara/dsl'
require 'selenium-webdriver'
require 'CSV'
require 'net/http'

http = Net::HTTP.new(@host, @port)
http.read_timeout = 500

Capybara.current_driver = :selenium
Capybara.app_host = ''

Capybara.default_max_wait_time = 5

module Crawler
  class A8
    include Capybara::DSL

    def login
      visit('')
      fill_in 'login',
              with: ''
      fill_in 'passwd',
              with: ''

      first('.lgnBtn').click_button 'ログイン'
    end

    def join_program
      visit('')
    end

    def create_adv_link(url, img)
      select('', from: 'bannerWebsiteId')

      fill_in 'bannerItemUrl',
              with: url
      fill_in 'bannerImageUrl',
              with: img
      first('.aslink02Btn').click_button '商品リンク作成'
    end

    def report

      temp_code = find(:xpath, '/html/body/div[2]/div/div/div[2]/div[2]/form/textarea').text
      temp_code
    end
  end
end

crawler = Crawler::A8.new
crawler.login
crawler.join_program

folder_name = ''
path = '' + folder_name

csv_str = path + '\\' + 're_sample.csv'
readoption = 'r:UTF-8'

write_path = '' + folder_name + '\\' + 'a8_code.csv'

csv_read = CSV.read(csv_str, readoption)

CSV.open(write_path, 'w:UTF-8') do |csv|

  a = []
  a.push(%w(url title category itemTitle stockState itemPrice itemPrice_addition
            detailUnderThumbH detailUnderThumb staffVoiceImg0 staffVoice0
            staffVoiceImg1 staffVoice1 staffVoiceImg2 staffVoice2 FeaturedImage code))


  csv << a.last

  csv_read.each_with_index do|_row, _i|
    a.clear
    next if _i == 0

    if _row[0].nil?
      csv << a
      next
    end

    puts
    _row.each_with_index do |_value, _i2|

      if _i2 < 15
        a.push(_value)
      else
        puts _value

        if _value.nil? || _value == ""
          next
        else
          crawler.create_adv_link(_row[0], _value)
          a.push(crawler.report)
          sleep(5)
        end

      end
    end

    a.insert(15, _row[15])
    csv << a
  end
end
