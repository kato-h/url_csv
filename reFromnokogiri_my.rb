# -*- coding: utf-8 -*-

require 'CSV'

folder_name = ''
path = '' + folder_name
csv_str = path + '\\' 'sample.csv'

doubleImgFile_str = path + '\\' 'imgDouble.csv'

readoption = 'r:UTF-8'

write_path = '' + folder_name + '\\' + 're_sample.csv'

doubleImgFile_read = CSV.read(doubleImgFile_str, readoption)

csv_read = CSV.read(csv_str, readoption)

CSV.open(write_path, 'w') do |csv|

  a = []

  a.push(%w(url title category itemTitle stockState itemPrice itemPrice_addition
            detailUnderThumbH detailUnderThumb staffVoiceImg0 staffVoice0
            staffVoiceImg1 staffVoice1 staffVoiceImg2 staffVoice2 img))

  csv << a.last

  csv_read.each_with_index do|_row, _i|
    a.clear
    next if _i == 0

    puts

    _row.each_with_index do |_value, _i2|

      if _i2 < 15
        a.push(_value)
      else
        check_double = false
        doubleImgFile_read.each do |double_value|
          if(_value == double_value[0])
            check_double = true
            break
          end
        end

        if check_double
          next
        else
          a.push(_value)
        end
      end
    end
    csv << a
  end
end
