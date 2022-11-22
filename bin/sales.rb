def calculate
  @goods_rates = { imported: 5, exempt: 0, others: 10 }
  @options = { sales_taxes: 0, total: 0, block_count: 0 }

  File.foreach('bin/inputs.txt') { |line| read_input line }
end

def read_input line
  process_line = -> (line) {

    if line.include?('-Input:')
      @options[:block_count] += 1
      puts "\nOutput: #{@options[:block_count]}"

    elsif (line.strip.empty?)
      puts "Sales Taxes: #{@options[:sales_taxes].round(2)}"
      puts "Total: #{@options[:total].round(2)}"

      @options = { sales_taxes: 0, total: 0, block_count: 0 }

    else
      get_result = -> (item) {
        ((item[2].strip.to_f + calculate_value_with_tax(item)) * item[0].to_i).round(2)
      }

      line_split = line.split(', ')
      process_item = -> (item) {
        @options[:total] += get_result.call(item)
        puts "#{item[0]} #{item[1]}: #{get_result.call(item)}"
      }

      process_item.call(line_split)

    end
  }

  process_line.call(line)
end

def apply_taxes?(options)
  options.include?(yield) if options != nil
end

def calculate_value_with_tax(item)

  tax_value = -> (value, tax_base) {
    rate = @goods_rates[tax_base.to_sym]
    if tax_base.nil?
      rate = @goods_rates[:others]
    end

    tax = ((value.to_f / 100) * rate).round(2)
    tax
  }

  item_value_with_tax = -> (taxes) {
    sum_taxes = []
    basic_sale_tax = -> (taxes) {
      taxes[2][0] = nil if taxes[0][0] == 0
    }
    basic_sale_tax.call(taxes)
    taxes.each do |tax|
      sum_taxes << tax[0]
    end

    sum_taxes.compact.sum()
  }

  goods_exempt = %[book chocolate pills]
  goods_imported = %[imported]

  ge = goods_exempt
         .split(' ')
         .map { |exempt| tax_value.call(item[2], 'exempt') if apply_taxes?(item[1]) { exempt } }

  gi = goods_imported
         .split(' ')
         .map { |imported| tax_value.call(item[2], 'imported') if apply_taxes?(item[1]) { imported } }

  gei = (goods_exempt.split(' ') + goods_imported.split(' ')).uniq
  go = gei.map { |others| tax_value.call(item[2], 'others') unless apply_taxes?(item[1]) { others } }

  tax_applied = item_value_with_tax.call([ge.compact, gi.compact, go.compact.uniq])

  @options[:sales_taxes] += tax_applied

  tax_applied
end

calculate
puts ""