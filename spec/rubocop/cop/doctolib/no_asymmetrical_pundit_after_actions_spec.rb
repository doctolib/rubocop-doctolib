# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Doctolib::NoAsymmetricalPunditAfterActions, :config do
  let(:config) { RuboCop::Config.new }

  message = 'Some actions may not be covered by either of `:verify_policy_scoped` or `:verify_authorized`. Prefer setting these with complementary `except` and `only` parameters.'

  it 'registers an offense for two only selectors' do
    expect_offense(<<~RUBY)
      class TestController
        after_action :verify_authorized, only: :show
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        after_action :verify_policy_scoped, only: :index
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      end
    RUBY
  end

  it 'registers an offense for asymmetrical only and except selectors' do
    expect_offense(<<~RUBY)
      class TestController
        after_action :verify_authorized, only: :show
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        after_action :verify_policy_scoped, except: :index
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      end
    RUBY
  end

  it 'does not register an offense when using symmetrical only and except selectors' do
    expect_no_offenses(<<~RUBY)
      class TestController
        after_action :verify_authorized, only: :show
        after_action :verify_policy_scoped, except: :show
      end
    RUBY
  end

  it 'does not register an offense when one filter applies to all actions' do
    expect_no_offenses(<<~RUBY)
      class TestController
        after_action :verify_authorized, only: :show
        after_action :verify_policy_scoped
      end
    RUBY
  end

  it 'does not register an offense when filters have disjoint except selectors' do
    expect_no_offenses(<<~RUBY)
      class TestController
        after_action :verify_authorized, except: :show
        after_action :verify_policy_scoped, except: %i[index destroy]
      end
    RUBY
  end

  it 'does not register an offense when the only selector is a superset of the except selector' do
    expect_no_offenses(<<~RUBY)
      class TestController
        after_action :verify_authorized, only: %i[foo bar qux]
        after_action :verify_policy_scoped, except: %i[foo bar]
      end
    RUBY
  end
end
