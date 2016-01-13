# -*- coding: utf-8 -*-
require 'CSV'

def checkDoubleImg(a, folder_name)
  doublevalue = {}

  a.each_with_index do |value, i|
    a.each_with_index do |value2, i2|
      if i != i2 && value == value2
        doublevalue[value] = 0 unless doublevalue.key? value
      end
    end
  end

  doublevalue.each_key do |key|
    puts %(<img src="#{key}" alt="" />)
  end

  write_path = '' + folder_name + '\\' + 'imgDouble.csv'

  if(false)
    CSV.open(write_path, 'w') do |csv|
      doublevalue.keys.each do |value|
        csv << [value]
      end
    end
  end
end

folder_name = ''

path = '' + folder_name
csv_str = path + '\\' 're_sample.csv'
readoption = 'r:UTF-8'

csv_read = CSV.read(csv_str, readoption)

a = []

csv_read.each_with_index do|_row, _i|
  next if _i == 0

  _row.each_with_index do |_url, _i2|
    next if _i2 < 15
    a.push(_url)
  end
end

checkDoubleImg(a, folder_name)
