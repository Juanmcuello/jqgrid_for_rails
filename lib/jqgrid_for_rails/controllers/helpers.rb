module JqgridForRails
  module Controllers
    # Those helpers are convenience methods added to ApplicationController.
    module Helpers
      
      # Returns a json string ready to be send to a jqgrid component.
      #
      # +records+ should be the result of an active record query through
      # the +paginate+ method offered by will_paginate.
      #
      # +columns+ is an array with the name of the fields in the order they
      # should be returned.
      #
      # options[:id_column] says which is the column that should be used as the row id
      # options[:page] says the page number
      #
      def json_for_jqgrid records, columns = nil, options = {}

        return if records.empty?

        columns ||= records.first.attributes.keys

        options[:id_column] ||= columns.first
        options[:page]      ||= 1

        { :page => options[:page],
          :total => records.total_pages,
          :records => records.total_entries,
          :rows => records.map do |r| {
            :id => r.attributes[options[:id_column]],
            :cell => r.attributes.values_at(*columns)}
          end
        }.to_json
      end
    
    end
  end
end

