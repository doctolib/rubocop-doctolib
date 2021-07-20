# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Doctolib::OneOperationPerMigration, :config do
  let(:config) { RuboCop::Config.new }

  it 'registers an offense when including multiple operations in a migration' do
    expect_offense(<<~RUBY)
      def change
      ^^^^^^^^^^ Use only one operation per migration.
        add_column :foos, :bar, :text
        add_column :foos, :qux, :text
      end
    RUBY
  end

  it 'does not register an offense when including a single operation in a migration' do
    expect_no_offenses(<<~RUBY)
      def change
        add_column :foos, :bar, :text
      end
    RUBY
  end

  it 'does not register an offense when including additional statements which are not migration operations' do
    expect_no_offenses(<<~RUBY)
      def change
        table_name = '  foos '.trim.to_sym
        add_column table_name, :bar, :text
      end
    RUBY
  end
end
