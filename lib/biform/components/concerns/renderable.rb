require "active_support/concern"

module Renderable
  extend ActiveSupport::Concern

  included do
    def read_attribute_for_validation(attr)
      send(attr)
    end

    def self.human_attribute_name(attr, _options = {})
      attr
    end

    def self.lookup_ancestors
      [self]
    end
  end
end
