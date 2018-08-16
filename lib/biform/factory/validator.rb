require "active_model"

class Biform::Factory::Validator
  HELPERS = %i[
    acceptance
    exclusion
    format
    inclusion
    length
    numericality
    presence
    size
  ].freeze

  def initialize(model_name, options)
    @model_name = model_name
    @options = options.to_h.slice(*HELPERS)
  end

  # rubocop:disable Layout/IndentationWidth
  def build
    return nil if @options.blank?

    validator = Class.new do
                  include ActiveModel::Validations

                  attr_reader :value

                  def initialize(value)
                    @value = value
                  end

                  def messages
                    errors.messages[:value]
                  end
    end

    validator.class_variable_set(:@@model_name, @model_name)
    validator.class_eval "def self.name; @@model_name; end"
    validator.class_eval "def self.model_name; @@model_name; end"

    validator.class_variable_set(:@@options, @options)
    validator.class_eval "validates :value, @@options"

    validator
  end
  # rubocop:enable Layout/IndentationWidth
end
