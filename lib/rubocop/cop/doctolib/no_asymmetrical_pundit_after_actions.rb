# frozen_string_literal: true

module RuboCop
  module Cop
    module Doctolib
      KEYS = %i[only except].freeze

      Verify =
        Struct.new(:node) do
          def arguments
            node.arguments[1...]
          end

          def covers_all?
            arguments.empty?
          end

          def mode
            only_or_except_kwarg&.key&.value
          end

          def actions
            actions = only_or_except_kwarg&.value
            return if actions.nil?
            normalize actions
          end

          private

          def only_or_except_kwarg
            hash = arguments.last
            return unless hash.type == :hash
            hash.pairs.find { |argument| KEYS.include? argument.key.value }
          end

          def normalize(value)
            case value.type
            when :sym
              Set[value.value]
            when :array
              return unless value.values.all? { |value| value.type == :sym }
              Set.new value.values.map(&:value)
            end
          end
        end

      # Prevent uses of the `verify_authorized` and `verify_policy_scoped`
      # after-action filters from Pundit, which potentially let some actions
      # covered by neither after-action filter.
      #
      # @example
      #
      #   # bad
      #   after_action :verify_policy_scoped, only: :show
      #   after_action :verify_authorized, only: :index
      #
      #   # bad
      #   after_action :verify_policy_scoped, only: :show
      #   after_action :verify_authorized, except: :index
      #
      #   # good
      #   after_action :verify_policy_scoped, only: :show
      #   after_action :verify_authorized, except: :show
      #
      #   # good
      #   after_action :verify_policy_scoped, only: :show
      #   after_action :verify_authorized
      #
      class NoAsymmetricalPunditAfterActions < Base
        def_node_matcher :verified_class?, <<~MATCHER
          (class _ _
            (begin <
              $(send nil? :after_action (sym :verify_policy_scoped) ...)
              $(send nil? :after_action (sym :verify_authorized) ...)
              ...>))
        MATCHER

        MSG = <<~MESSAGE.chomp.gsub("\n", ' ')
          Some actions may not be covered by either of `:verify_policy_scoped` or `:verify_authorized`.
          Prefer setting these with complementary `except` and `only` parameters.
        MESSAGE

        def on_class(node)
          verified_class?(node) do |policy_scoped, authorized|
            policy_scoped = Verify.new policy_scoped
            authorized = Verify.new authorized
            return if policy_scoped.covers_all?
            return if authorized.covers_all?
            return if only_superset_of_except? policy_scoped, authorized
            return if disjoint_excepts? policy_scoped, authorized
            add_offense policy_scoped.node
            add_offense authorized.node
          end
        end

        private

        def only_superset_of_except?(policy_scoped, authorized)
          if policy_scoped.mode != authorized.mode
            only, except = policy_scoped.mode == :only ? [policy_scoped, authorized] : [authorized, policy_scoped]
            return true if only.actions >= except.actions
          end
        end

        def disjoint_excepts?(policy_scoped, authorized)
          policy_scoped.mode == :except && authorized.mode == :except &&
            policy_scoped.actions.disjoint?(authorized.actions)
        end
      end
    end
  end
end
