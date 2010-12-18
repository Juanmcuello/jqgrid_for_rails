module JqgridsHelper

  def jqgrid grid_id, options = {}, grid_options = {}, nav_options = {}

    html_output = []

    # Table
    html_output << content_tag(:table, nil, :id => grid_id)  unless options[:no_html]
    js_output   =  "jQuery(\"##{grid_id}\").jqGrid(#{grid_options.to_json});"

    # Pager
    if grid_options[:pager]

      pager_id = id_from_pager_option(grid_options[:pager])

      html_output << content_tag(:div, nil, :id => pager_id) unless options[:no_html]

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

