class Biform::Model::Bridge
  attr_reader :impl

  delegate :template, :attributes, :associations, :sync, :save, :to_key, :to_param, :id, :persisted?, to: :impl

  def initialize(record)
    case adapter(record)
    when :activerecord
      @impl = Biform::Model::Activerecord.new(record)
    when :sequel
      @impl = Biform::Model::Sequel.new(record)
    end
  end

  private

  def adapter(record)
    if record.class.superclass.to_s == "ApplicationRecord"
      :activerecord
    elsif record.class.superclass.to_s == "ActiveRecord::Base"
      :activerecord
    elsif record.respond_to?(:db) && record.db.class.superclass.to_s == "Sequel::Database"
      :sequel
    else
      raise ArgumentError, "Unknown database adapter"
    end
  end
end
