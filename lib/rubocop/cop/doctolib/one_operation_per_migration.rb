# frozen_string_literal: true

module RuboCop
  module Cop
    module Doctolib
      # Flag ActiveRecord database migrations which contain more than one
      # operation.
      #
      # @example
      #
      #   # bad
      #   def change
      #     add_column :foos, :bar, :text
      #     add_column :foos, :qux, :text
      #   end
      #
      #   # good
      #   def change
      #     add_column :foos, :bar, :text
      #   end
      #
      class OneOperationPerMigration < RuboCop::Cop::Cop
        MSG = 'Use only one operation per migration.'

        # From: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html
        def_node_matcher(:migration_symbol?, <<~PATTERN)
          {
            :add_check_constraint
            :add_column
            :add_columns
            :add_foreign_key
            :add_index
            :add_index_options
            :add_reference
            :add_timestamps
            :change_column
            :change_column_comment
            :change_column_default
            :change_column_null
            :change_table
            :change_table_comment
            :check_constraints
            :create_join_table
            :create_table
            :disable_extension
            :drop_join_table
            :drop_table
            :enable_extension
            :execute
            :execute_block
            :remove_check_constraint
            :remove_column
            :remove_columns
            :remove_foreign_key
            :remove_index
            :remove_reference
            :remove_timestamps
            :rename_column
            :rename_index
            :rename_table
            :update_table_definition
            :validate_check_constraint
            :validate_constraint
            :validate_foreign_key
          }
        PATTERN

        # Descendent of migration class calls migration symbol
        def_node_matcher(:migration_operation?, <<~PATTERN)
          {
            (send nil? #migration_symbol? ...)
          }
        PATTERN

        def on_def(node)
          migration_count = 0
          each_child_recursive(node) do |child|
            next unless migration_operation?(child)

            migration_count += 1
            add_offense(node) if migration_count > 1
          end
        end

        private

        def each_child_recursive(node)
          children_stack = [node] # Initialize stack with root node.
          until children_stack.empty?
            # Iterate until all leaves have been found.
            child = children_stack.pop # Select one child from the stack.

            # Add all the next children to the stack if this node-type can have children.
            children_stack.push(*child.children) if child.respond_to?(:children)

            yield(child)
          end
        end
      end
    end
  end
end
