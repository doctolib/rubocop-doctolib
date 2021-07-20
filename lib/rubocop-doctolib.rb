# frozen_string_literal: true

require 'rubocop'

require_relative 'rubocop/doctolib'
require_relative 'rubocop/doctolib/version'
require_relative 'rubocop/doctolib/inject'

RuboCop::Doctolib::Inject.defaults!

require_relative 'rubocop/cop/doctolib_cops'
