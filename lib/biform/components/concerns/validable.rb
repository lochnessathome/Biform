require "active_support/concern"

module Validable
  extend ActiveSupport::Concern

  included do
    def valid?
      return false if attributes.values.any? { |attr| !attr.valid? }
      return false if associations.values.any? { |assoc| !assoc.valid? }
      return false if collections.values.any? { |coll| !coll.valid? }

      true
    end

    def errors
      list = ActiveModel::Errors.new(self)

      attributes.each do |key, val|
        next if val.valid?

        val.errors.each do |err|
          list.add(key, err)
        end
      end

      associations.each do |key, val|
        list.add(key, "association is invalid") unless val.valid?
      end

      collections.each do |key, val|
        list.add(key, "collection is invalid") unless val.valid?
      end

      list
    end
  end
end
