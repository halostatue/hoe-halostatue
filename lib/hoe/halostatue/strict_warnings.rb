# frozen_string_literal: true

$VERBOSE = true
Warning[:deprecated] = true

module Hoe::Halostatue::StrictWarnings # :nodoc:
  class << self
    attr_accessor :project_root
    attr_reader :allowed
    attr_reader :suppressed

    def allowed=(patterns)
      @allowed = Regexp.union(*Array(patterns))
    end

    def suppressed=(patterns)
      @suppressed = Regex.union(*Array(patterns))
    end
  end

  WarningError = Class.new(StandardError)

  def warn(message, ...)
    pattern = Hoe::Halostatue::StrictWarnings.suppressed
    return if pattern&.match?(message)

    super

    return unless ENV["STRICT_WARNINGS"] || ENV["CI"]

    project_root = Hoe::Halostatue::StrictWarnings.project_root
    return if project_root && !message.include?(project_root)

    pattern = Hoe::Halostatue::StrictWarnings.allowed
    return if pattern&.match?(message)

    raise WarningError.new(message)
  end
end

Warning.singleton_class.prepend(Hoe::Halostatue::StrictWarnings)
