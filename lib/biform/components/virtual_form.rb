require_relative "concerns/populable"
require_relative "concerns/validable"
require_relative "concerns/renderable"
require_relative "concerns/inspectable"
require_relative "concerns/serializable"

class Biform::Components::VirtualForm
  include Populable
  include Validable
  include Renderable
  include Inspectable
  include Serializable

  def initialize(name)
    @name = name.to_s.camelize
    @attributes = {}
    @associations = {}
    @collections = {}

    instance_eval "def model; nil; end"
    instance_eval "def attributes; @attributes; end"
    instance_eval "def associations; @associations; end"
    instance_eval "def collections; @collections; end"
  end

  def model_name
    form_name = @name.sub(/(::)?Form$/, "")

    ::ActiveModel::Name.new(self.class, nil, form_name)
  end

  def to_key
    nil
  end

  def to_param
    nil
  end

  # def to_model
  #  self
  # end

  def id
    nil
  end

  def persisted?
    false
  end

  def keys
    attributes.keys + associations.keys + collections.keys
  end

  def sync
    true
  end

  def save
    true
  end
end
