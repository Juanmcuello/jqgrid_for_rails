module JqgridForRails
  module Controllers
    # Those helpers are convenience methods added to ApplicationController.
    module Helpers

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
      #   the row id.
      #
      # * <tt>:id_prefix</tt> - If specified, the +column_id+ option will be
      #   concatenated to this prefix. This helps to keep the html id unique in
      #   the document.
      #
      # * <tt>:translate</tt> - Array with the name of the fields that should be
      #   localized with the <tt>I18n.l</tt> method. The field content must be
      #   of any class accepted by the method. I.e. Time, DateTime, Date.
      #
      # * <tt>:page</tt> - Says the page number (Deprecated. The page number is
      #   now inferred from +records+.
      #
      def json_for_jqgrid records, columns = nil, options = {}

        columns ||= (records.first.attributes.keys rescue [])

        options[:id_column] ||= columns.first
        options[:page]      ||= records.current_page

        { :page     => options[:page],
          :total    => records.total_pages,
          :records  => records.total_entries,
          :rows     => records.map {|r| row_from_record(r, columns, options)}
        }.to_json
      end

      # Returns the 'order by' string created using the params received from the jqgrid.
      #
      # ==== Example
      #
      #   order_by_from_params({'sidx' => 'updated_at', 'sord' => 'asc'})
      #   #=> 'updated_at asc'
      #
      def order_by_from_params params
        order_by = params['sidx'] unless params['sidx'].blank?
        order_by << " #{params['sord']}" if params['sord'] && order_by
        order_by
      end

    private

      # Returns a hash with the values for a jqgrid json row.
      def row_from_record(r, columns, options)
        attribs = r.attributes

        # Localize Date, Time or DateTime fields
        locale_classes = [Time, Date, DateTime]
        if options[:translate].is_a?(Array) && I18n
          options[:translate].each do |col|
            attribs[col.to_s] = I18n.l(attribs[col.to_s]) if locale_classes.include?(attribs[col.to_s].class)
          end
        end

        {:id => "#{options[:id_prefix]}#{attribs[options[:id_column]]}",
         :cell => attribs.values_at(*columns) }
      end

    end
  end
end

