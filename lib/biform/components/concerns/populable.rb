require "active_support/concern"

module Populable
  extend ActiveSupport::Concern

  included do
    def prepopulate!(options = {}, context = self)
      attributes.values.each { |attr| attr.prepopulate!(options, context) }
      associations.values.each { |assoc| assoc.prepopulate!(options) }
      collections.values.each { |coll| coll.prepopulate!(options) }

      true
    end

    def populate!(options = {}, context = self)
      attributes.values.each { |attr| attr.populate!(options, context) }
      associations.values.each { |assoc| assoc.populate!(options) }
      collections.values.each { |coll| coll.populate!(options) }

      true
    end
  end
end
