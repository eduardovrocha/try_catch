require 'byebug'

def calculate
  input_block_count = 0
  sales_taxes = 0
  total = 0

  inspect_line = -> (line) {

    if line.empty?
      calculate_total {{ sales_taxes: sales_taxes, total: total }}

    elsif (line.include?('-Input:'))
      input_block_count += 1
      puts "\nOutput: #{input_block_count}"

    else
      line_split = line.split(',')
      item_qtd = line_split[0].strip
      item_value = line_split[2].strip.to_f

      ge = goods_except.split(' ').map { |except_item|
        calculate_tax(line_split[2], 'exempt') if apply_taxes(line_split[1]) { except_item }
      }
      ii = imported_items.split(' ').map { |imported_item|
        calculate_tax(line_split[2], 'imported') if apply_taxes(line_split[1]) { imported_item }
      }

      basic_taxes = -> (item_value) {
        return [].push((item_value/100)*10) if (ge.compact.empty? && ii.compact!.nil?)
      }

      taxes = [ge.compact!, ii, basic_taxes.call(item_value)]

      # byebug
      puts "#{item_qtd} #{line_split[1]} -  -- #{taxes}"
    end
  }

  File.foreach("bin/inputs.txt") { |line| inspect_line.call(line[0...-1]) }
  puts ""
end

def calculate_total

  yield

  puts "Sales Taxes: 7.90"
  puts "Total: 7.90"

end

def calculate_tax item_value, origin
  ((item_value.strip.to_f/100)*goods_rate[origin.to_sym]).round(2)
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