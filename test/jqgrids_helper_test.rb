require File.dirname(__FILE__) + '/test_helper.rb'

class MockView < ActionView::Base
  include JqgridsHelper
end

class JqgridsHelperTest < Test::Unit::TestCase

  def test_jqgrid_small

    @template = MockView.new

    grid_id = 'grid_id'
    grid_options = [{:url => "/jqGridModel?model=Wine" }]

    expected =  '<script>' + "\n"
    expected <<    'jQuery("#'+grid_id+'").jqGrid({"url":"/jqGridModel?model=Wine"});' + "\n"
    expected << '</script>'

    assert_equal(expected, @template.jqgrid_api(grid_id, grid_options, {:script_tags => true}))

  end

  def test_jqgrid_medium

    @template = MockView.new

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

  def test_jqgrid_nav_options
    @template = MockView.new

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

  def test_pager_id_from_options
    @template = MockView.new

    assert_equal 'my_pager_div', @template.send(:pager_id_from_options, {:pager => "jQuery('#my_pager_div')"})
    assert_equal 'my_pager_div', @template.send(:pager_id_from_options, {:pager => 'jQuery("#my_pager_div")'})
    assert_equal 'my_pager_div', @template.send(:pager_id_from_options, {:pager => "#my_pager_div"})
    assert_equal 'my_pager_div', @template.send(:pager_id_from_options, {:pager => "my_pager_div"})
  end

  def test_chained_functions
    @template = MockView.new
    div_id = 'my_grid'
    nav_button =  [:navButtonAdd, '#pager', { :caption => 'Add'}]
    nav_separator =  [:navSeparatorAdd, '#pager']

    expected = 'jQuery("#'+div_id+'").jqGrid("navButtonAdd", "#pager", {"caption":"Add"}).jqGrid("navSeparatorAdd", "#pager");'

    assert_equal expected, @template.jqgrid_api(div_id, nav_button, nav_separator, {:script_tags => false})

  end

end
