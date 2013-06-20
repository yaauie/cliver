# encoding: utf-8
require 'cliver/version'
require 'cliver/which'
require 'cliver/assertion'
require 'cliver/detector'
require 'cliver/detector/default'

module Cliver
  # See Cliver::Assertion#assert
  def self.assert(*args, &block)
    Assertion.assert!(*args, &block)
  end

  extend self

  # Wraps Cliver::assert and returns truthy/false instead of raising
  # @see Cliver::assert
  # @return [False,String] either returns false or the reason why the
  #                        assertion was unmet.
  def dependency_unmet?(*args, &block)
    Cliver.assert(*args, &block)
    false
  rescue Assertion::DependencyNotMet => error
    # Cliver::Assertion::VersionMismatch -> 'Version Mismatch'
    reason = error.class.name.split('::').last.gsub(/(?<!\A)[A-Z]/, " \\0")
    "#{reason}: #{error.message}"
  end
end
