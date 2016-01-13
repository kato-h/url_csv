# -*- coding: utf-8 -*-

require 'CSV'

def outputShortcode(code_arg, url_arg, i_arg, a_arg, category_value)

  md = url_arg.match(/\/(\w+-\w+)/)
  str = md[1].sub(/-/, '_')

  funcname = "ezak_#{category_value}_#{str}_#{i_arg}"
  a_arg.push('[' + funcname + ']')
  puts <<"EOF"
function #{funcname}() {
  return <<<'EOD'
#{code_arg}
EOD;
}
add_shortcode('#{funcname}', '#{funcname}');
EOF
  puts
end

category_value = 0

category_name = ''

path = '' + '\\' + category_name

csv_str = path + '\\' 'a8_code.csv'
readoption = 'r:UTF-8'

write_path = '' + '\\' + category_name + '\\' + "shortCode#{category_value}.csv"

shopName = ''
brandName = ''

exeCreateShortCode = false

csv_read = CSV.read(csv_str, readoption)

temp_length = 0
csv_read.each_with_index do|_row, _i|
  next if _i == 0
  temp_length = _row.length if temp_length < _row.length
end

CSV.open(write_path, 'w:UTF-8') do |_csv|

  a = []

  a = %w(shopName brandName url title noStockState stockState category categoryPrice itemPriceValue itemTitle  itemPrice itemPrice_addition
            detailUnderThumbH detailUnderThumb staffVoiceImg0 staffVoice0
            staffVoiceImg1 staffVoice1 staffVoiceImg2 staffVoice2)
  createShortcode_h = {}

  a.each_with_index do |value, i|
    createShortcode_h[value] = i
  end

  login_a = %w(url title category itemTitle stockState itemPrice itemPrice_addition
               detailUnderThumbH detailUnderThumb staffVoiceImg0 staffVoice0
               staffVoiceImg1 staffVoice1 staffVoiceImg2 staffVoice2 code)

  login_h = {}
  login_h2 = {}

  login_a.each_with_index do |value, i|
    login_h[value] = i
  end

  temp_length -= 15

  (0...temp_length).each do |_i|
    if exeCreateShortCode
      a.push("shortCode#{_i}")
    else
      a.push("code#{_i}")
      puts "{code#{_i}[1]}"
    end

  end

  _csv << a

  csv_read.each_with_index do|_row, _i|
    a.clear
    if _i == 0
      next
    elsif _row[0].nil?
      _csv << a
      next
    end

    i_funcname = 0

    login_h2.clear
    _row.each_with_index do |_value, _i2|
      if _i2 < login_h['code']
        login_h2[login_a[_i2]] = _value
        a[createShortcode_h[login_a[_i2]]] = _value
      else

        next if _value.nil? || _value == '' || _value == ""

        if exeCreateShortCode
          outputShortcode(_value, _row[login_h['url']], i_funcname, a, category_value)
          i_funcname += 1
        else
          puts _value
          a.push(_value)
        end

      end
    end

    a[createShortcode_h['shopName']] = shopName
    a[createShortcode_h['brandName']] = brandName

    a[createShortcode_h['noStockState']] = login_h2['stockState']
    a[createShortcode_h['stockState']] = '在庫あり' if (a[createShortcode_h['noStockState']] == "")

    temp_i = _row[login_h['itemPrice']].sub(/円/, '').sub(/,/, '')
    temp_f = temp_i.to_f / 1000

    if temp_f < 1
      a[createShortcode_h['categoryPrice']] = _row[2] + '1000円未満'
    else
      a[createShortcode_h['categoryPrice']] = _row[2] + (temp_f.floor * 1000).to_s + '円台'
    end
    a[createShortcode_h['itemPriceValue']] = temp_i.to_s

    _csv << a
  end
end
