# frozen_string_literal: true

module Hoe::Halostatue::Checklist
  # An array of reminder questions that should be asked before a release, in the form,
  attr_accessor :checklist

  private

  def initialize_halostatue_checklist
    self.checklist = [
      "bump the version",
      "check everything in",
      "review the manifest",
      "update the README and docs",
      "update the changelog",
      "regenerate the gemspec"
    ]
  end

  def define_halostatue_checklist_tasks
    desc "Show a reminder for steps frequently forgotten in a manual release"
    task :checklist do
      if checklist.nil? || checklist.empty?
        puts "Checklist is empty."
      else
        puts "\n### HEY! Did you...\n\n"

        checklist.each do |question|
          question = question[0..0].upcase + question[1..]
          question = "#{question}?" unless question.end_with?("?")
          puts "  * #{question}"
        end

        puts
      end
    end

    task :release_sanity do
      unless checklist.nil? || checklist.empty? || trusted_release
        Rake::Task[:checklist].invoke
        puts "Hit return if you're sure, Ctrl-C if you forgot something."
        $stdin.gets
      end
    end
  end
end
