# frozen_string_literal: true

module Hoe::Halostatue::Gemspec
  # Whether a fixed date should be used for reproducible gemspec values. This is ignored
  # if `$SOURCE_DATE_EPOCH` is set. Acceptable values are:
  #
  #   - `:default` or `true`: uses the RubyGems default source date epoch
  #   - `:current`: uses the date stored in the most recent gemspec file
  #   - `false`: sets the release date to the current date
  #   - An epoch value, either as an Integer or a String
  #
  # [default: `:default`]
  attr_accessor :reproducible_gemspec

  private

  LINKS = /\[(?<name>.+?)\](?:\(.+?\)|\[.+?\])/ # :nodoc:
  PERMITTED_CLASSES = [ # :nodoc:
    Symbol, Time, Date, Gem::Dependency, Gem::Platform, Gem::Requirement,
    Gem::Specification, Gem::Version, Gem::Version::Requirement
  ].freeze
  PERMITTED_SYMBOLS = %i[development runtime].freeze # :nodoc:

  private_constant :LINKS, :PERMITTED_CLASSES, :PERMITTED_SYMBOLS

  def initialize_halostatue_gemspec
    self.reproducible_gemspec = :default
  end

  def define_halostatue_gemspec_tasks
    gemspec = "#{spec.name}.gemspec"

    with_config do
      unless ".gemspec".match?(_1["exclude"])
        warn "WARNING You should add .gemspec to your .hoerc exclude list"
      end
    end

    epoch = resolve_source_date_epoch
    ENV["SOURCE_DATE_EPOCH"] = epoch&.to_s

    file gemspec => %w[clobber Manifest.txt] + spec.files do
      spec2 = resolve_gemspec
      spec2.date = epoch if spec2.respond_to?(:date=)

      clear_rubygem_signing(spec2)
      clean_markdown_links(spec2)

      File.write(gemspec, spec2.to_ruby)
    end

    desc "Regenerate #{gemspec}"
    task gemspec: gemspec
    task default: gemspec
  end

  def clear_rubygem_signing(spec)
    spec.signing_key = spec.default_value(:signing_key)
    spec.cert_chain = spec.default_value(:cert_chain)
  end

  def clean_markdown_links(spec)
    spec.description = spec.description.gsub(LINKS, '\k<name>').gsub(/\r?\n/, " ")
    spec.summary = spec.summary.gsub(LINKS, '\k<name>').gsub(/\r?\n/, " ")
  end

  def resolve_source_date_epoch
    epoch = ENV["SOURCE_DATE_EPOCH"]
    epoch = nil if !epoch.nil? && epoch.strip.empty?

    if epoch
      Time.at(epoch.to_i).utc.freeze
    elsif reproducible_gemspec == :default || reproducible_gemspec == true
      Gem.source_date_epoch
    elsif reproducible_gemspec == :current
      Gem::Specification.load(gemspec)&.date&.freeze || Gem.source_date_epoch
    elsif reproducible_gemspec.is_a?(String)
      Time.at(reproducible_gemspec.to_i).utc.freeze
    elsif reproducible_gemspec.is_a?(Integer)
      Time.at(reproducible_gemspec).utc.freeze
    elsif reproducible_gemspec == false
      nil
    else
      raise ArgumentError,
        "Invalid value for `reproducible_gemspec`: #{reproducible_gemspec.inspect}"
    end
  end

  def resolve_gemspec
    YAML.safe_load(
      YAML.safe_dump(
        spec,
        permitted_classes: PERMITTED_CLASSES,
        permitted_symbols: PERMITTED_SYMBOLS,
        aliases: true
      ),
      permitted_classes: PERMITTED_CLASSES,
      permitted_symbols: PERMITTED_SYMBOLS,
      aliases: true
    )
  rescue
    YAML.safe_load(YAML.dump(spec), PERMITTED_CLASSES, PERMITTED_SYMBOLS, true)
  end
end
