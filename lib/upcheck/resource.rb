# frozen_string_literal: true

module Upcheck
  class Resource
    def self.attribute(*names)
      names.each do |name|
        define_method(name) { @attributes[name.to_s] }
      end
    end

    def initialize(attributes)
      @attributes = attributes || {}
    end
  end
end
