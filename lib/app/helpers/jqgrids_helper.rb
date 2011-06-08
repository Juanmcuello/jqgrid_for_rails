module JqgridsHelper

  # Generates the jqGrid javascript code. This method returns a jqgrid api function after parsing the
  # received parameters. If more than one function is specified in the parameters, all the resulting
  # functions will be chained.
  #
  # ==== Parameters
  #
  # * <tt>grid_id</tt> - This is the id of the html table tag that will contain the grid.
  # * <tt>*args</tt> - Each item in the args array will be translated to a jqgrid api function. Each item
  #   should be an array whose elements will be encoded to json to create the jqgrid api function.
  #   All subsequent functions after the first one will be chained.
  #   See the examples for details.
  #
  # ==== Options
  #
  # This method accepts an options hash as their last parameter. The accepted options are:
  #
  # * <tt>:script_tags</tt> - If <tt>false</tt>, <tt><script></tt> tags will not be generated. Default +true+.
  #
  # * <tt>:on_document_ready</tt> - If <tt>true</tt>, all the javascript code will be enclosed inside a <tt>jQuery(document).ready</tt> function.
  #
  # ==== Examples
  #
  # A simple call to generate a navigation bar:
  #
  #   jqgrid_api 'invoices_list', [:navGrid, '#invoices_pager', {:search => true, :refresh => false}]
  #     #=> jQuery("#invoices_list").jqGrid("navGrid", "#invoices_pager", {"search":true,"refresh":false});
  #
  # A more complete example, to create a grid and a pager with a custom button, without the script tags
  # and with the js code enclosed inside a <tt>jQuery(document).ready</tt> function.
  #
  #   options = {:on_document_ready => true, :html_tags => false}
  #
  #   grid = [{
  #     :url => '/invoices',
  #     :datatype => 'json',
  #     :mtype => 'GET',
  #     :colNames => ['Inv No','Date', 'Amount','Tax','Total','Notes'],
  #     :colModel  => [
  #       { :name => 'invid',   :index => 'invid',    :width => 55 },
  #       { :name => 'invdate', :index => 'invdate',  :width => 90 },
  #       { :name => 'amount',  :index => 'amount',   :width => 80,   :align => 'right' },
  #       { :name => 'tax',     :index => 'tax',      :width => 80,   :align => 'right' },
  #       { :name => 'total',   :index => 'total',    :width => 80,   :align => 'right' },
  #       { :name => 'note',    :index => 'note',     :width => 150,  :sortable => false }
  #     ],
  #     :pager => '#invoices_pager',
  #     :rowNum => 10,
  #     :rowList => [10, 20, 30],
  #     :sortname => 'invid',
  #     :sortorder => 'desc',
  #     :viewrecords => true,
  #     :caption => 'My first grid',
  #     :onSelectRow => "function() { alert('Row selected!');}".to_json_var
  #   }]
  #
  #   pager = [:navGrid, "#invoices_pager", {:del => true }, {}, {}, {:closeOnEscape => true}]
  #
  #   pager_button = [:navButtonAdd, "#invoices_pager", {:caption => 'Add', :onClickButton => 'function() {alert("Button!")}'.to_json_var }]
  #
  #   jqgrid_api 'invoices_list', grid, pager, pager_button, options
  #
  #
  def jqgrid_api div_id, *args

    options = args.extract_options!

    options[:on_document_ready] ||= false
    options[:script_tags] = true if options[:script_tags].nil?

    result = args.map do |v|
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
  # 1. <tt>jQuery('#my_pager_div')</tt>
  # 2. <tt>#my_pager_div</tt>
  # 3. <tt>my_pager_div</tt>
  #
  # ==== Example
  #
  #   pager_id_from_options({:pager => "jQuery('#my_pager_id')"})
  #     #=> 'my_pager_id'
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

  # Returns an array to be used as col_model for the grid where each item
  # is a hash for each column. Each hash will have at least two keys by
  # default, the +name+ and the +index+, whose values will be the name of
  # the column. Other keys will be included if present in the +options+
  # hash.
  #
  # * +columns+ - Array with the name of the columns to include in the
  #   col_model.
  #
  # ==== Options
  #
  # Every item in the options hash will be a property in the col_model for
  # every column, unless the item is also a hash, where only will be included
  # in the specified columns. An item can be also a Proc, that will be called
  # passing +columns+ as parameter.
  #
  # ==== Examples
  #
  #   col_model_for_jqgrid(['inv_date', 'total' ])
  #
  #     #=> [{:name=>"inv_date", :index=>"inv_date"}, {:name=>"total", :index=>"total"}]
  #
  #   col_model_for_jqgrid(['inv_date', 'total' ], {:width => 100})
  #
  #     #=> [{:name=>"inv_date", :index=>"inv_date", :width=>100}, {:name=>"total", :index=>"total", :width=>100}]
  #
  #   col_model_for_jqgrid(['inv_date', 'total'], {:width => {'inv_date' => 100}})
  #
  #     #=> [{:name => 'inv_date', :index => 'inv_date', :width => 100}, {:name => 'total', :index => 'total'}]
  #
  #   col_model_for_jqgrid(['inv_date'], {:prop => Proc.new {|c| c.camelize}})
  #
  #     #=> [{:name => 'inv_date', :index => 'inv_date', :prop => 'InvDate'}]
  #
  def col_model_for_jqgrid columns, options = {}
    columns.map do |c|
      h = {:name => c, :index => c}
      h.merge property_from_options(c, options)
    end
  end

private

  def wrap_with_document_ready! str
    str.replace("jQuery(document).ready(function() {#{str}});")
  end

  def wrap_with_script_tags! str
    str.replace("<script>\n#{str}\n</script>")
  end

  def property_from_options col_name, options
    h = {}
    options.each do |k, v|
      case v.class.to_s
      when "Proc"
        h[k] = v.call(col_name)
      when "Hash"
        h[k] = v[col_name] if v.has_key?(col_name)
      else
        h[k] = v
      end
    end
    h
  end

end

