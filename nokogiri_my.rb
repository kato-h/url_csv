# -*- coding: utf-8 -*-

require 'nokogiri'
require 'open-uri'
require 'CSV'

def get_jpg(url, csv)

  #doc = Nokogiri.HTML(open(url))
  doc = Nokogiri.HTML(open(url, :proxy => 'http://localhost:5432'))

  # a.push(%w(url title category itemTitle itemPrice itemPrice_addition img))
  temp_a = []

  temp_a.push(url)
  temp_a.push(doc.title)
  temp_a.push(doc.xpath('//p[@class = "pan FS2_breadcrumbs_1"]/a[3]').text)

  temp_a.push(doc.xpath('//h1[@class = "itemTitle"]').text)
  if doc.xpath('//p[@class = "itemStock FS2_noStockText"]').length == 0
    temp_a.push('')
  else
    temp_a.push('在庫切れ中')
  end

  temp_a.push(doc.xpath('//span[@class = "itemPrice"]').text.sub(/,/, ''))
  temp_a.push(doc.xpath('//span[@class = "FS2_itemPrice_addition"]').text)

  temp_a.push(doc.xpath('//div[@id="detailColumnUnderThumbInner"]/h2').text)
  temp_a.push(doc.xpath('//div[@id="detailColumnUnderThumbInner"]/p').text)

  (1..3).each do |i|
    if doc.xpath(%(//div[@id="staffCommentBox"][#{i}]/a/img[1])).length > 0
      temp_a.push(doc.xpath(%(//div[@id="staffCommentBox"][#{i}]/a/img[1])).attribute('src').value)
    else
      temp_a.push('')
    end
    temp_a.push(doc.xpath(%(//div[@id="staffCommentBox"][#{i}])).text)
  end

  doc.xpath('//img').each do |element|
    next unless element.attribute('src').value.match(%r{\Ahttp://image.+\d\.jpg\z}) &&
                !element.attribute('src').value.match(%r{bn\d+}) &&
                !element.attribute('src').value.match(%r{/bnr}) &&

    temp_a.push(element.attribute('src'))
  end
  doc.xpath('//*[@id="detailColumnUnderThumbNavi"]/a/img[1]').each do |element|
    md = element.attribute('src').value.match(%r{(http://.+.jpg)})
    temp_a.push(md[0]) if !md[0].match(%r{bn\d+}) && !md[0].match(%r{/bnr})
  end

  if temp_a[19].nil?

    doc.xpath('//div[@class="FS2_additional_image_container_sub"]/span/img').each do |element|

      md = element.attribute('src').value.match(%r{(http://.+.jpg)})

      if !md[0].match(%r{bn\d+}) && !md[0].match(%r{/bnr})
        temp_a.push(md[0].sub(/ds.jpg/, 'dl.jpg'))
      end

    end
  end

  if temp_a[19].nil?

    doc.xpath('//div[@class="FS2_additional_image_container_main"]/span/img').each do |element|
      md = element.attribute('src').value.match(%r{(http://.+.jpg)})

      if !md[0].match(%r{bn\d+}) && !md[0].match(%r{/bnr})
        temp_a.push(md[0].sub(/ds.jpg/, 'dl.jpg'))
      end

    end
  end

end


folder_name = ''
path = '' + folder_name
csv_str = path + '\\' + 'url.csv'
readoption = 'r:UTF-8'

write_path = '' + folder_name + '\\' + 'sample.csv'

csv_read = CSV.read(csv_str, readoption)

CSV.open(write_path, 'w:UTF-8') do |csv|

  a = []

  a.push(%w(url title category itemTitle stockState itemPrice itemPrice_addition
            detailUnderThumbH detailUnderThumb staffVoiceImg0 staffVoice0
            staffVoiceImg1 staffVoice1 staffVoiceImg2 staffVoice2 img))

  csv << a.last

  csv_read.each_with_index do|_row, _i|
    next if _i == 0
    puts

    _row.each_with_index do |_url, _i2|
      next if _i2 < 4
      puts _url
      get_jpg(_url, csv)
      sleep(10)

    end
  end
end
