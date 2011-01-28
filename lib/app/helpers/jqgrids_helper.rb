module JqgridsHelper

  # Generates the jqGrid javascript code. Also html tags for the table and pager can be generated.
  # The javascript code is enclosed between the <script> tags.
  #
  # The +grid_id+ parameter should be the id of the html table tag that will contain the grid.
  # If [:html_tags] is +true+, the grid_id will be used when creating the <table> tags.
  #
  # === Options
  #
  # [:script_tags]
  #   If false, <script> tags will not be generated. Default true.
  #
  # [:on_document_ready]
  #   If true, all the javascript code will be enclosed inside a +jQuery(document).ready+ function
  #
  # === Functions
  #
  # This is an array where each item is an array of parameters for each java script fuction to create
  # in the js string.
  #
  # In the simplest case, it will be an array of just one item (that will be an array also) with the
  # main grid options. These options can be any option accepted by the jqGrid. Each item will be encoded
  # to json to create the javascript code for the grid.
  #
  # See http://www.trirand.com/jqgridwiki/doku.php?id=wiki:options
  #
  # For options that represents javascript functions, the value should be converted to a json_var
  # using the +to_json_var+ method.
  #
  # For example:
  #   :onLoadComplete => "function() { alert('This is a function!');}".to_json_var
  #
  # === Example
  #
  #  options = {:on_document_ready => true, :script_tags => false}
  #
  #  grid_options = [{
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
  #  }]
  #
  #  pager_options = [:navGrid, "#my_pager_id", {:del => true }, {}, {}, {:closeOnEscape => true}]
  #
  #  to_jqgrid_api 'invoices_list', [grid_options, pager_options], options
  #
  def to_jqgrid_api div_id, functions, options = {}

    options[:on_document_ready] ||= false
    options[:script_tags] = true if options[:script_tags].nil?

    result = functions.map do |v|
      ".jqGrid(#{v.map { |v| (v || {}).to_json}.join(', ')})"
    end
    js = "jQuery(\"##{div_id}\")" + result.join('') + ';'

    wrap_with_document_ready!(js)  if options[:on_document_ready]
    wrap_with_script_tags!(js)     if options[:script_tags]
    js
  end


  # Extracts the pager id from the options hash.
  #
  # jQgrid accepts three different formats to set the pager id option.
  #
  # 1 - jQuery('#my_pager_div')
  # 2 - #my_pager_div
  # 3 - my_pager_div
  #
  # === Example
  #
  #   pager_id_from_options({:pager => "jQuery('#my_pager_id')"})
  #     => 'my_pager_id'
  #
  def pager_id_from_options options
    pager_option = options[:pager]

    # jQuery('#my_pager_div')
    if pager_option =~ /^jQuery\(('|")#\w+('|")\)$/
      pager_option.match(/#\w+/).to_s[1..-1]
    # #my_pager_div
    elsif pager_option =~ /^#\w+$/
      pager_option.match(/#\w+/).to_s[1..-1]
    # my_pager_div
    else
      pager_option
    end
  end

private

  def wrap_with_document_ready! str
    str.replace("jQuery(document).ready(function() {#{str}});")
  end

  def wrap_with_script_tags! str
    str.replace("<script>\n#{str}\n</script>")
  end

end

