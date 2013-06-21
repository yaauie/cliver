# encoding: utf-8

module Cliver
  # A Namespace to hold filter procs
  module Filter
    # The identity filter returns its input unchanged.
    IDENTITY = proc { |version| version }

    def requirements(requirements)
      requirements.map do |requirement|
        *anchor, version = requirement.split(/\b(?=\d)/, 2)
        (anchor.dup << call(version)).join
      end
    end
  end
end
