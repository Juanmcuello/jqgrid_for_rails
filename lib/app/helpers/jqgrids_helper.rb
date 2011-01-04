module JqgridsHelper

  # Generates the jqGrid javascript code. Also html tags for the table and pager can be generated.
  # The javascript code is enclosed between the <script> tags.
  #
  # The +grid_id+ parameter should be the id of the html table tag that will contain the grid.
  # If [:html_tags] is +true+, the grid_id will be used when creating the <table> tags.
  #
  # === Options
  #
  # [:html_tags]
  #   If true, <table> tag for the grid, and <div> tag for the table will be generated as well.
  #
  # [:on_document_ready]
  #   If true, all the javascript code will be enclosed inside a +jQuery(document).ready+ function
  #
  # === Grid Options
  #
  # This hash can contain any option accepted by the jqGrid. The has will encoded to json to create
  # the javascript code for the grid.
  #
  # See http://www.trirand.com/jqgridwiki/doku.php?id=wiki:options
  #
  # For options that represents javascript functions, the value should be converted to a json_var
  # using the +to_json_var+ method.
  #
  # For example:
  # :onLoadComplete => "function() { alert('This is a function!');}".to_json_var
  #
  # === Nav Options
  #
  # This hash can contain any option accepted by the nav options of jqGrid.
  #
  # === Example
  #
  #  options = {:on_document_ready => true, :html_tags => false}
  #
  #  grid_options = {
  #    :url => '/invoices',
  #    :datatype => 'json',
  #    :mtype => 'GET',
  #    :colNames => ['Inv No','Date', 'Amount','Tax','Total','Notes'],
  #    :colModel  => [
  #      { :name => 'invid',   :index => 'invid',    :width => 55 },
  #      { :name => 'invdate', :index => 'invdate',  :width => 90 },
  #      { :name => 'amount',  :index => 'amount',   :width => 80,   :align => 'right' },
  #      { :name => 'tax',     :index => 'tax',      :width => 80,   :align => 'right' },
  #      { :name => 'total',   :index => 'total',    :width => 80,   :align => 'right' },
  #      { :name => 'note',    :index => 'note',     :width => 150,  :sortable => false }
  #    ],
  #    :pager => '#invoices_pager',
  #    :rowNum => 10,
  #    :rowList => [10, 20, 30],
  #    :sortname => 'invid',
  #    :sortorder => 'desc',
  #    :viewrecords => true,
  #    :caption => 'My first grid',
  #    :onSelectRow => "function() { alert('Row selected!');}".to_json_var
  #  }
  #
  #  jqgrid 'invoices_list', options, grid_options
  #
  def jqgrid grid_id, options = {}, grid_options = {}, nav_options = {}

    html_output = []

    # Table
    html_output << content_tag(:table, nil, :id => grid_id) if options[:html_tags]
    js_output   =  "jQuery(\"##{grid_id}\").jqGrid(#{grid_options.to_json});"

    # Pager
    if grid_options[:pager]

      pager_id = id_from_pager_option(grid_options[:pager])

      html_output << content_tag(:div, nil, :id => pager_id) if options[:html_tags]

      if nav_options
        js_output << "jQuery(\"##{grid_id}\").jqGrid(\"navGrid\", \"##{pager_id}\", #{nav_options.to_json});"
      end
    end

    wrap_with_document_ready! js_output if options[:on_document_ready]

    html_output << "<script>" << js_output << "</script>"

    html_output.join("\n")
  end

private

  def wrap_with_document_ready! str
    str.replace("jQuery(document).ready(function() {#{str}});")
  end

  def id_from_pager_option pager_option
    pager_option.match(/#\w+/).to_s[1..-1]
  end

end

