require "action_view/test_case"
require File.dirname(__FILE__) + '/test_helper.rb'

class MockView < ActionView::Base
  include JqgridsHelper
end

class JqgridsHelperTest < ActionView::TestCase

  def setup
    @template = MockView.new
  end

  test "jqgrid small" do

    grid_id = 'grid_id'
    grid_options = [{:url => "/jqGridModel?model=Wine" }]

    expected =  '<script>' + "\n"
    expected <<    'jQuery("#'+grid_id+'").jqGrid({"url":"/jqGridModel?model=Wine"});' + "\n"
    expected << '</script>'

    assert_equal(expected, @template.jqgrid_api(grid_id, grid_options, {:script_tags => true}))
  end

  test "jqgrid_medium" do

    grid_id       = 'grid_id'
    pager_id      = 'gridpager'
    grid_options  = [{:pager => "jQuery('##{pager_id}')".to_json_var }]

    options   = {:on_document_ready => true }
    expected  = expected_grid(grid_id, pager_id, options)
    assert_equal(expected, @template.jqgrid_api(grid_id, grid_options, options))

    options   = {:on_document_ready => true }
    expected  = expected_grid(grid_id, pager_id, options)
    assert_equal(expected, @template.jqgrid_api(grid_id, grid_options, options))
  end

  test "jqgrid nav_options" do

    grid_id       = 'grid_id'
    pager_id      = 'pager_id'
    grid_options  = {:pager => "##{pager_id}"}
    options       = {:on_document_ready => true, :script_tags => true}

    expected  = "<script>" + "\n"
    str       =   'jQuery("#'+grid_id+'").jqGrid({"pager":"#'+pager_id+'"}).jqGrid("navGrid", "#'+pager_id+'", {"del":true}, {}, {}, {"closeOnEscape":true});'
    expected <<   "jQuery(document).ready(function() {#{str}});" + "\n"
    expected << "</script>"

    assert_equal(expected, @template.jqgrid_api(grid_id, [grid_options], [:navGrid, "##{pager_id}", {:del => true }, {}, {}, {:closeOnEscape => true}], options))
  end

  test "pager_id_from_options" do
    assert_equal 'my_pager_div', @template.send(:pager_id_from_options, {:pager => "jQuery('#my_pager_div')"})
    assert_equal 'my_pager_div', @template.send(:pager_id_from_options, {:pager => 'jQuery("#my_pager_div")'})
    assert_equal 'my_pager_div', @template.send(:pager_id_from_options, {:pager => "#my_pager_div"})
    assert_equal 'my_pager_div', @template.send(:pager_id_from_options, {:pager => "my_pager_div"})
  end

  test "chained_functions" do
    div_id = 'my_grid'
    nav_button =  [:navButtonAdd, '#pager', { :caption => 'Add'}]
    nav_separator =  [:navSeparatorAdd, '#pager']

    expected = 'jQuery("#'+div_id+'").jqGrid("navButtonAdd", "#pager", {"caption":"Add"}).jqGrid("navSeparatorAdd", "#pager");'

    assert_equal expected, @template.jqgrid_api(div_id, nav_button, nav_separator, {:script_tags => false})

  end

  test "col_model_for_jqgrid should return a valid model for the grid" do
    columns = ['inv_date', 'amount', 'total' ]
    result  = @template.col_model_for_jqgrid(columns)
    assert_equal [
      {:name => 'inv_date', :index => 'inv_date'},
      {:name => 'amount', :index => 'amount'},
      {:name => 'total', :index => 'total'}
      ], result
  end

  test "col_model_for_jqgrid with default width for every column" do
    columns = ['inv_date', 'amount', 'total' ]
    result  = @template.col_model_for_jqgrid(columns, {:width => 100})
    assert_equal [
      {:name => 'inv_date', :index => 'inv_date', :width => 100},
      {:name => 'amount', :index => 'amount', :width => 100},
      {:name => 'total', :index => 'total', :width => 100}
      ], result
  end

  test "col_model_for_jqgrid with explicity width for some columns" do
    columns = ['inv_date', 'amount', 'total' ]
    result  = @template.col_model_for_jqgrid(columns, {:width => {'inv_date' => 100, 'total' => 150}})
    assert_equal [
      {:name => 'inv_date', :index => 'inv_date', :width => 100},
      {:name => 'amount', :index => 'amount'},
      {:name => 'total', :index => 'total', :width => 150}
      ], result
  end

  test "col_model_for_jqgrid with explicity property for some columns" do
    columns = ['inv_date', 'amount', 'total' ]
    result  = @template.col_model_for_jqgrid(columns, {:property_1 => {'inv_date' => 'high', 'total' => 'low'}, :property_2 => true})
    assert_equal [
      {:name => 'inv_date', :index => 'inv_date', :property_1 => 'high', :property_2 => true},
      {:name => 'amount', :index => 'amount', :property_2 => true},
      {:name => 'total', :index => 'total', :property_1 => 'low', :property_2 => true}
      ], result
  end

  test "col_model_for_jqgrid with proc as property" do
    columns = ['inv_date', 'amount', 'total' ]
    result  = @template.col_model_for_jqgrid(columns, {:property_1 => Proc.new {|c| c.camelize}})
    assert_equal [
      {:name => 'inv_date', :property_1 => 'InvDate', :index => 'inv_date'},
      {:name => 'amount', :property_1 => 'Amount', :index => 'amount'},
      {:name => 'total', :property_1 => 'Total', :index => 'total'}
      ], result
  end

private

  def expected_grid grid_id, pager_id, options

    options[:script_tags] ||= true

    js =  'jQuery(document).ready(function() {
            jQuery("#' + grid_id + '").jqGrid({
              "pager":jQuery(\'#' + pager_id + '\')
            });
          });'
    js.gsub!(/\n\s+/, '')
    js = "<script>\n#{js}\n</script>" if options[:script_tags]
    js

  end

end
