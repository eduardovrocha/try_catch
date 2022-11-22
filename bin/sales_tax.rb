require 'byebug'

def calculate
  input_block_count = 0

  inspect_line = -> (line) {
    line_split = line.split(',')
    if line_split.size > 0

      if line.include?('-Input:')
        input_block_count += 1
      else

        item_qtd = line_split[0].strip
        item_value = line_split[2].strip.to_f

        ge = goods_except.split(' ').map { |except_item|
          item_value = item_value + calculate_tax(line_split[2], 'exempt') if apply_taxes(line_split[1]) { except_item }
        }

        ii = imported_items.split(' ').map { |imported_item|
          item_value = item_value + calculate_tax(line_split[2], 'imported') if apply_taxes(line_split[1]) { imported_item }
        }

        taxes = [ge.compact!, ii.compact!]
        puts "#{line_split[1]} - #{line_split[2]} -- #{taxes}"


        format_output = -> () {
          # puts "#{line_split[0]}, #{line_split[1]}, #{item_value.round(2)} - #{(item_value * line_split[0].to_i).round(2)}"
        }

        calculate_total(item_value, item_qtd) { |item, qtd| format_output }

      end
    end
  }

  File.foreach("bin/inputs.txt") { |line| inspect_line.call(line[0...-1]) }
end

def calculate_total item_value, qtd
  yield
end

def calculate_tax item_value, origin
  (item_value.to_f / 100) * goods_rate[origin.to_sym]
end

def goods_rate
  { imported: 5, exempt: 0, others: 10 }
end

def apply_taxes(options)
  options.include?(yield) if options != nil
end

def goods_except
  %[book chocolate pills]
end

def imported_items
  %[imported]
end

calculate