# Rubocop::Doctolib

rubocop-doctolib is a RuboCop extension containing various cops used and
produced at Doctolib. Many of them are useful only in the context of a Ruby on
Rails application.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rubocop-doctolib', require: false
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rubocop-doctolib

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`bundle exec rake test` and `bundle exec rake spec` to run the tests. You can
also run `bin/console` for an interactive prompt that will allow you to
experiment.

To add a new cop, run `bundle exec rake 'new_cop[Doctolib/NewCopName]'` and
implement the cop and its tests.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and the created tag, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/doctolib/rubocop-doctolib.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
