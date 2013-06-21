# encoding: utf-8

module Cliver
  # A Namespace to hold filter procs
  module Filter
    # The identity filter returns its input unchanged.
    IDENTITY = proc { |version| version }

    def requirements(requirements)
      requirements.map do |requirement|
        req_parts = requirement.split(/\b(?=\d)/, 2)
        version = req_parts.last
        version.replace call(version)
        req_parts.join
      end
    end
  end
end
