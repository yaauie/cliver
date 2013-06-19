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
end
