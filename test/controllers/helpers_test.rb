require 'test/test_helper' 

class MockController < ApplicationController
end

class ControllerHelpersTest < ActionController::TestCase

  def setup
    @controller = MockController.new
  end

  tests MockController

  test "order_by_from with sidx and sord" do
    params = {'sidx' => 'updated_at', 'sord' => 'desc' }
    assert_equal 'updated_at desc', @controller.order_by_from_params(params)
  end

  test "order_by_from with sidx" do
    params = {'sidx' => 'updated_at'}
    assert_equal 'updated_at', @controller.order_by_from_params(params)
  end

  test "order_by_from without sidx" do
    params = {'sord' => 'desc' }
    assert_nil @controller.order_by_from_params(params)
  end

  test "order_by_from with blank sidx" do
    params = {'sidx' => ''}
    assert_nil @controller.order_by_from_params(params)
  end

  test "json_for_grid with empty records result" do
    records = Invoice.paginate(:page => 1)
    json    = @controller.json_for_jqgrid(records)
    hash    = ActiveSupport::JSON.decode(json)
    assert_equal 0, hash['total']
    assert_equal [], hash['rows']
    assert_equal 1, hash['page']
    assert_equal 0, hash['records']
  end

  test "json_for_grid with one record and id prefix" do
    tmp_record  = Invoice.create({:invid => 1, :invdate => '2011-01-01 00:00:00', :amount => 10, :tax => 1, :total => 11, :note => '' })
    records     = Invoice.paginate(:page => 1)
    json        = @controller.json_for_jqgrid(records, ['invdate', 'amount', 'total' ], {:id_column => 'invid', :id_prefix => 'mygrid_row_'})
    hash        = ActiveSupport::JSON.decode(json)
    Invoice.delete(tmp_record.id)
    assert_equal hash["total"], 1
    assert_equal hash["page"], 1
    assert_equal hash["records"], 1
    assert_equal hash["rows"][0]["cell"], ["2011-01-01T00:00:00Z", 10.0, 11.0]
    assert_equal hash["rows"][0]["id"], "mygrid_row_1"
  end

  test "col_model_for_jqgrid should return a valid model for the grid" do
    columns = ['inv_date', 'amount', 'total' ]
    result  = @controller.col_model_for_jqgrid(columns)
    assert_equal [
      {:name => 'InvDate', :index => 'InvDate'},
      {:name => 'Amount', :index => 'Amount'},
      {:name => 'Total', :index => 'Total'}
      ], result
  end

  test "col_model_for_jqgrid with default width for every column" do
    columns = ['inv_date', 'amount', 'total' ]
    result  = @controller.col_model_for_jqgrid(columns, {:width => 100})
    assert_equal [
      {:name => 'InvDate', :index => 'InvDate', :width => 100},
      {:name => 'Amount', :index => 'Amount', :width => 100},
      {:name => 'Total', :index => 'Total', :width => 100}
      ], result
  end

  test "col_model_for_jqgrid with explicity width for some columns" do
    columns = ['inv_date', 'amount', 'total' ]
    result  = @controller.col_model_for_jqgrid(columns, {:width => {'inv_date' => 100, 'total' => 150}})
    assert_equal [
      {:name => 'InvDate', :index => 'InvDate', :width => 100},
      {:name => 'Amount', :index => 'Amount'},
      {:name => 'Total', :index => 'Total', :width => 150}
      ], result
  end

  test "col_model_for_jqgrid with explicity property for some columns" do
    columns = ['inv_date', 'amount', 'total' ]
    result  = @controller.col_model_for_jqgrid(columns, {:property_1 => {'inv_date' => 'high', 'total' => 'low'}, :property_2 => true})
    assert_equal [
      {:name => 'InvDate', :index => 'InvDate', :property_1 => 'high', :property_2 => true},
      {:name => 'Amount', :index => 'Amount', :property_2 => true},
      {:name => 'Total', :index => 'Total', :property_1 => 'low', :property_2 => true}
      ], result
  end

  test "col_model_for_jqgrid with proc as property" do
    columns = ['inv_date', 'amount', 'total' ]
    result  = @controller.col_model_for_jqgrid(columns, {:property_1 => Proc.new {|c| c.camelize}})
    assert_equal [
      {:name => 'InvDate', :property_1 => 'InvDate', :index => 'InvDate'},
      {:name => 'Amount', :property_1 => 'Amount', :index => 'Amount'},
      {:name => 'Total', :property_1 => 'Total', :index => 'Total'}
      ], result
  end

end
