require_relative "concerns/populable"
require_relative "concerns/validable"
require_relative "concerns/renderable"
require_relative "concerns/inspectable"
require_relative "concerns/serializable"

class Biform::Components::RealForm
  include Populable
  include Validable
  include Renderable
  include Inspectable
  include Serializable

  def initialize(record)
    @record = record
    @model = Biform::Model::Bridge.new(record)
    @attributes = {}
    @associations = {}
    @collections = {}

    instance_eval "def model; @model; end"
    instance_eval "def attributes; @attributes; end"
    instance_eval "def associations; @associations; end"
    instance_eval "def collections; @collections; end"
  end

  def model_name
    form_name = @record.class.name.sub(/(::)?Form$/, "")

    ::ActiveModel::Name.new(self.class, nil, form_name)
  end

  def to_key
    @model.to_key
  end

  def to_param
    @model.to_param
  end

  # def to_model
  #  self
  # end

  def id
    @model.id
  end

  def persisted?
    @model.persisted?
  end

  def keys
    attributes.keys + associations.keys + collections.keys
  end

  def sync
    return false unless valid?

    attributes.each do |key, val|
      @model.sync(key, val.get)
    end

    associations.values.each(&:sync)
    collections.values.each(&:sync)

    true
  end

  # rubocop:disable Lint/HandleExceptions
  def save(&block)
    return false unless sync

    if block
      block.call(serialize)
    else
      status = false

      begin
        ActiveRecord::Base.transaction do
          @model.save
          associations.values.each { |assoc| raise ActiveRecord::Rollback unless assoc.save }
          collections.values.each { |coll| raise ActiveRecord::Rollback unless coll.save }

          status = true
        end
      rescue
      end

      status
    end
  end
  # rubocop:enable Lint/HandleExceptions
end
