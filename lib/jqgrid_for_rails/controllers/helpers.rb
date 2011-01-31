module JqgridForRails
  module Controllers
    # Those helpers are convenience methods added to ApplicationController.
    module Helpers
      
      # Returns a json string ready to be sent to a jqgrid component.
      #
      # +records+ should be the result of an active record query through
      # the +paginate+ method offered by will_paginate.
      #
      # +columns+ is an array with the name of the fields in the order they
      # should be returned.
      #
      # === Options
      #
      # [:id_column]
      #   Says which is the column that should be used as the row id
      #
      # [:page]
      #   Says the page number (Deprecated. The page number is now inferred from +records+)
      #
      def json_for_jqgrid records, columns = nil, options = {}

        columns ||= (records.first.attributes.keys rescue [])

        options[:id_column] ||= columns.first
        options[:page]      ||= records.current_page

        { :page => options[:page],
          :total => records.total_pages,
          :records => records.total_entries,
          :rows => records.map do |r| {
            :id => r.attributes[options[:id_column]],
            :cell => r.attributes.values_at(*columns)}
          end
        }.to_json
      end

      # Returns the 'order by' string created using the params received from the jqgrid.
      #
      # === Example
      #
      #   order_by_from_params({'sidx' => 'updated_at', 'sord' => 'asc'})
      #   => 'updated_at asc'
      #
      def order_by_from_params params
        order_by = params['sidx'] unless params['sidx'].blank?
        order_by << " #{params['sord']}" if params['sord'] && order_by
        order_by
      end
    
    end
  end
end

