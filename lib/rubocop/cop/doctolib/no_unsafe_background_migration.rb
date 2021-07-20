# frozen_string_literal: true

module RuboCop
  module Cop
    module Doctolib
      # Flag migrations which alter the “shape” of the schema.
      #
      # @example
      #
      #   # bad
      #   add_column :foos, :bar, :text
      #
      #   # good
      #   add_index :foos, :bar
      #
      class NoUnsafeBackgroundMigration < RuboCop::Cop::Cop
        MSG = 'Only use background migrations for index creation, column deletion or table deletion.'

        def_node_matcher(:unsafe_operation_method?, <<~PATTERN)
          {
            :create_join_table
            :create_table
            :add_column
            :add_reference
            :add_timestamps
            :change_column
            :change_column_default
            :change_column_null
            :change_table
            :rename_column
            :rename_table
          }
        PATTERN

        def_node_matcher(:unsafe_operation?, <<~PATTERN)
          (send nil? #unsafe_operation_method? ...)
        PATTERN

        def on_send(node)
          add_offense(node) if unsafe_operation?(node)
        end
      end
    end
  end
end
