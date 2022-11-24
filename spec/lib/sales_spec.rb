# Basic sales tax is applicable at a rate of 10% on all goods, except books,
# food, and medical products that are exempt. Import duty is an additional
# sales tax applicable on all imported goods at a rate of 5%, with no
# exemptions

require 'spec_helper'
require 'byebug'

require_relative '../../bin/sales/sales'

describe 'sales' do

  it 'calculate tax by value and description' do
    expect(calculate_value_with_tax(["2", "book at", "12.49\n"])).to eq (0.0)
    expect(calculate_value_with_tax(["1", "imported box of chocolates at", "12.49\n"])).to eq (0.62)
    expect(calculate_value_with_tax(["1", "music CD at", "12.49\n"])).to eq (1.25)
  end

  it 'should apply tax' do
    expect(apply_taxes?("book at")).to_not others
  end

end