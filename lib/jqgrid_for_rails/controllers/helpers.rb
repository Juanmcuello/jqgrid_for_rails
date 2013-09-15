module JqgridForRails
  module Controllers
    # Those helpers are convenience methods added to ApplicationController.
    module Helpers

      # DEPRECATED! Moved to jqgrids_helper.rb
      def col_model_for_jqgrid columns, options = {}
        columns.map do |c|
          h = {:name => c, :index => c}
          h.merge property_from_options(c, options)
        end
      end

      # Returns a json string ready to be sent to a jqgrid component.
      #
      # * +records+ - Should be the result of an active record query through
      #   the +paginate+ method offered by will_paginate.
      # * +columns+ - Array with the name of the fields in the order they
      #   should be returned.
      #
      # ==== Options
      #
      # * <tt>:id_column</tt> - Says which is the column that should be used as
      #   the row id. This should a be the column name, but it can also be a
      #   Proc, in which case the record will be passed to the proc. See examples
      #   for more info.
      #
      # * <tt>:id_prefix</tt> - If specified, the +column_id+ option will be
      #   concatenated to this prefix. This helps to keep the html id unique in
      #   the document.
      #
      # * <tt>:translate</tt> - Array with the name of the fields that should be
      #   localized with the <tt>I18n.l</tt> method. The field content must be
      #   of any class accepted by the method. I.e. Time, DateTime, Date.
      #
      # * <tt>:format</tt> - Says the proc and the columns where to apply it. It
      #   can be used to change the format of the field as well as to run any other
      #   code on it. If the key of the hash is not a column name but an array of
      #   column names, the proc is applied to all of them.
      #
      # * <tt>:page</tt> - Says the page number (Deprecated. The page number is
      #   now inferred from +records+.
      #
      # ==== Examples
      #
      #   records = Invoice.paginate(:page => 1)
      #   my_proc = Proc.new {|r| "invid_#{r.invid}" }
      #   json_for_jqgrid(records, ['invdate', 'amount', 'total' ], {:id_column => my_proc })
      #
      #   # => {"rows":[{"cell":["2011-01-01T00:00:00Z",10.0,11.0],"id":"invid_1"}],"total":1,"page":1,"records":1}
      #
      #   records   = Invoice.paginate(:page => 1)
      #   my_format = Proc.new {|val| val + 100 }
      #   json_for_jqgrid(records, ['invdate', 'amount', 'total' ], {:format => { 'total' => my_format })
      #
      #   # Because of the :format option, 100 is added to 'total' field.
      #   # => {"rows":[{"cell":["2011-01-01T00:00:00Z",10.0,111.0],"id":"invid_1"}],"total":2,"page":1,"records":1}
      #
      def json_for_jqgrid records, columns = nil, options = {}

        columns ||= (records[0].attributes.keys rescue [])

        options[:id_column] ||= columns.first
        options[:page]      ||= records.current_page

        { :page     => options[:page],
          :total    => records.total_pages,
          :records  => records.total_entries,
          :rows     => records.map {|r| row_from_record(r, columns, options)}
        }.to_json
      end

      # Returns the 'order by' string created using the params received from the jqgrid.
      # If +quote_char+ is specified, the column name used in the 'order by' clause will
      # be quoted.
      #
      # ==== Example
      #
      #   order_by_from_params({'sidx' => 'updated_at', 'sord' => 'asc'})
      #   #=> 'updated_at asc'
      #
      #   order_by_from_params({'sidx' => 'updated_at', 'sord' => 'desc'}, '`')
      #   #=> '`updated_at` desc'
      #
      def order_by_from_params params, quote_char = nil
        order_by = quote(params['sidx'], quote_char) unless params['sidx'].blank?
        order_by << " #{params['sord']}" if params['sord'] && order_by
        order_by
      end

    private

      def quote value, quote_char
        "#{quote_char}#{value}#{quote_char}"
      end

      # Returns a hash with the values for a jqgrid json row.
      def row_from_record(r, columns, options)

        attribs = columns.each_with_object({}) do |column, hash|
          hash[column] = column.split('.').inject(r) { |o, a| o.public_send(a) }
        end

        localize(attribs, options[:translate]) if options[:translate]

        format(attribs, options[:format]) if options[:format]

        {
          :id   => "#{options[:id_prefix]}#{id_column_from_options(r, options)}",
          :cell => attribs.values_at(*columns)
        }
      end

      def id_column_from_options record, options
        if options[:id_column].class.to_s == 'Proc'
          options[:id_column].call(record)
        else
          record.attributes[options[:id_column]]
        end
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

      # Localize Date, Time or DateTime fields
      def localize attribs, translate
        locale_classes = [Time, Date, DateTime]
        if translate.is_a?(Array) && I18n
          translate.each do |col|
            attribs[col.to_s] = I18n.l(attribs[col.to_s]) if locale_classes.include?(attribs[col.to_s].class)
          end
        end
      end

      # Format fields
      def format attribs, format
        if format.is_a?(Hash)
          format.each do |col, pr|
            if col.is_a?(Array)
              col.each {|c| attribs[c] = pr.call(attribs[c])}
            else
              attribs[col] = pr.call(attribs[col])
            end
          end
        end
      end

    end
  end
end

