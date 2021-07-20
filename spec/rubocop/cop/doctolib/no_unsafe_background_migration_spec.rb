# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Doctolib::NoUnsafeBackgroundMigration, :config do
  it 'registers an offense on migrations that alter the schema’s “shape”' do
    expect_offense(<<~RUBY)
      add_column :foos, :bar, :text
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Only use background migrations for index creation, column deletion or table deletion.
    RUBY
  end

  it 'does not register an offense on migrations that do not alter the schema’s “shape”' do
    expect_no_offenses(<<~RUBY)
      add_index :foos, :bar
    RUBY
  end
end
