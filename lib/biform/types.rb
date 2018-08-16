# Types::Custom::Money
# FIXME: проверить работу пользовательских типов

module Biform::Types
  require "dry-types"

  include Dry::Types.module

  DEFAULT = Dry::Types.module::Any
  AR_MAP = {
    string: Biform::Types::Coercible::String,
    text: Biform::Types::Coercible::String,
    integer: Biform::Types::Coercible::Int,
    float: Biform::Types::Coercible::Float,
    decimal: Biform::Types::Coercible::Decimal,
    array: Biform::Types::Coercible::Array,
    hash: Biform::Types::Coercible::Hash,
    boolean: Biform::Types::Bool,
    date: Biform::Types::Date,
    time: Biform::Types::Time,
    datetime: Biform::Types::DateTime,
  }.freeze

  def self.detect(type)
    return DEFAULT if type.nil? # здесь важно различие между nil и false

    return type if type.class.superclass == Dry::Types::Definition
    return type if type.class == Dry::Types::Constrained
    return AR_MAP[type] if type.instance_of?(::Symbol) && AR_MAP.keys.include?(type)
    return Dry::Types["#{type}"] if Dry::Types.type_keys.include?("#{type}")

    DEFAULT
  end
end
