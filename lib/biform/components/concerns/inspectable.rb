require "active_support/concern"

module Inspectable
  extend ActiveSupport::Concern

  included do
    def inspect
      formatted_attributes = attributes.map do |key, val|
        "#{key} = #{val.get.nil? ? 'nil' : val.get}"
      end

      formatted_associations = associations.map do |key, val|
        if val.klass.instance_of?(Symbol)
          "#{key} = :#{val.klass}"
        else
          "#{key} = #{val.klass}"
        end
      end

      formatted_collections = collections.map do |key, val|
        if val.klass.instance_of?(Symbol)
          "#{key} = :#{val.klass}"
        else
          "#{key} = #{val.klass}"
        end
      end

      summary = {
        attributes: formatted_attributes.join(", "),
        associations: formatted_associations.join(", "),
        collections: formatted_collections.join(", "),
      }

      formatted_summary = summary.map { |key, val| "#{key}: [#{val}]" }.join(", ")

      "<#{self.class} #{formatted_summary}>"
    end
  end
end
