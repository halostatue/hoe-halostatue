# frozen_string_literal: true

gem "minitest"
require "minitest/autorun"
require "minitest/focus"

if ENV["STRICT"]
  $VERBOSE = true
  Warning[:deprecated] = true
  require "minitest/error_on_warning"
end
