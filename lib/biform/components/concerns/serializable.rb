require "active_support/concern"

module Serializable
  extend ActiveSupport::Concern

  included do
    def serialize
      buf = {}

      attributes.each do |key, val|
        buf[key] = val.get
      end

      associations.each do |key, val|
        buf[key] = val.serialize
      end

      collections.each do |key, val|
        buf[key] = val.serialize
      end

      buf
    end
  end
end
