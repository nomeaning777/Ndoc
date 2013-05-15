require 'test/unit'
require File.dirname(__FILE__) + '/../lib/ndoc/ndoc_parser'

class TestNDocParser < Test::Unit::TestCase
  def setup
  end

  def test_create
    @obj = Ndoc::NdocParser.new('')
  end
end
