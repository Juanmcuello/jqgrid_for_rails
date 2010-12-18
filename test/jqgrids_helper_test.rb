require File.dirname(__FILE__) + '/test_helper.rb'

class MockView < ActionView::Base
  include JqgridsHelper
end

class JqgridsHelperTest < Test::Unit::TestCase

  def test_jqgrid_small

    @template = MockView.new

    grid_id = 'grid_id'
    grid_options = { :url => "/jqGridModel?model=Wine" }

    expected  = '<table id="'+grid_id+'"></table>' + "\n"
    expected << '<script>' + "\n"
    expected <<    'jQuery("#'+grid_id+'").jqGrid({"url":"/jqGridModel?model=Wine"});' + "\n"
    expected << '</script>'

    assert_equal(expected, @template.jqgrid(grid_id, {} , grid_options))

  end

  def test_jqgrid_medium

    @template = MockView.new

    grid_id = 'grid_id'
    pager_id = 'gridpager'
    grid_options = { :pager => "jQuery('##{pager_id}')".to_json_var }

    options = {:on_document_ready => true }
    expected = expected_grid(grid_id, pager_id, options)
    assert_equal(expected, @template.jqgrid(grid_id, options, grid_options))

    options = {:on_document_ready => true, :no_html => true }
    expected = expected_grid(grid_id, pager_id, options)
    assert_equal(expected, @template.jqgrid(grid_id, options, grid_options))
  end

  def expected_grid grid_id, pager_id, options
    expected = ''
    expected << '<table id="'+grid_id+'"></table>' + "\n" unless options[:no_html]
    expected << '<div id="'+pager_id+'"></div>' + "\n" unless options[:no_html]
    expected << '<script>' + "\n"

    js =  'jQuery(document).ready(function() {
            jQuery("#' + grid_id + '").jqGrid({
              "pager":jQuery(\'#' + pager_id + '\')
            });
            jQuery("#grid_id").jqGrid("navGrid", "#gridpager", {});
          });'
    expected << js.gsub(/\n\s+/, '') + "\n"
    expected << '</script>'

  end

end
