RSpec.configure do |config|
  config.color = true

  config.before(:all) {
    @goods_rates = { imported: 5, exempt: 0, others: 10 }
    @options = { sales_taxes: 0, total: 0, block_count: 0 }
  }
end