module ActiveRecordAnonymizer
  module Strategies
    class TextAnonymizer
      attr_reader :table_name, :column_name, :options
      def initialize(table_name, column_name, options = {})
        @table_name = table_name
        @column_name = column_name
        @options = options
      end

      def base_dictionary
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZCáéíóúÁÉÍÓÚçÇãÃõÕ1234567890@"
      end

      def anonymize
        adapter = ActiveRecord::Base.connection.instance_values["config"][:adapter]
        case adapter
        when "postgresql"
          "translate((#{table_name}.#{column_name})::text, '#{self.base_dictionary}'::text, '#{generate_mapping()}'::text)"
        else
          raise "#{self.class.name} not implemented for #{adapter}"
        end
      end

      private
      def generate_mapping
        base_array = self.base_dictionary.split("")
        base_array.map do |char|
          base_array.sample
        end.join("")
      end
    end
  end
end
