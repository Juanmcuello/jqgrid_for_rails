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

end
