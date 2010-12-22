require File.dirname(__FILE__) + '/test_helper.rb'

class JqgridForRailsTest < Test::Unit::TestCase
  load_schema

  class Invoices < ActiveRecord::Base
  end

  def test_schema_has_loaded_correctly
    assert_equal [], Invoices.all
  end

end
