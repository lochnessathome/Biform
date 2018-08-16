class Biform::Factory::Attribute
  DEFAULT_OPTS = { virtual: false, type: nil, nilify: false, writeable: true, readable: true }.freeze

  def initialize(property, form)
    @property = property
    @form = form

    @name = property.name
    @virtual = property.options[:virtual] || DEFAULT_OPTS[:virtual]
  end

  def build
    attribute = if @virtual
                  build_virtual
                else
                  if @form.model && @form.model.attributes.keys.include?(@name)
                    build_real
                  else
                    build_virtual
                  end
                end

    @form.instance_variable_set("@attributes", @form.attributes.merge(@name => attribute))

    @form.instance_eval "def #{@name}; @attributes[:#{@name}].get; end;"
    @form.instance_eval "def #{@name}=(value); @attributes[:#{@name}].set(value); end;"
  end

  private

  def build_real
    options = @form.model.attributes[@name].slice(:type, :default)
    options = DEFAULT_OPTS.merge(options)
    options = options.merge(@property.options)

    attribute = Biform::Components::Attribute.new(
      false,
      options[:namespace],
      Biform::Types.detect(options[:type]),
      options[:default],
      options[:nilify],
      options[:writeable],
      options[:readable],
      options[:prepopulator],
      options[:populator],
      Biform::Factory::Validator.new(@form.model_name, options[:validates]).build
    )

    if value = @form.model.attributes[@name][:value]
      attribute.set(value)
    else
      attribute.default!
    end

    attribute
  end

  def build_virtual
    options = DEFAULT_OPTS.merge(@property.options)

    attribute = Biform::Components::Attribute.new(
      true,
      options[:namespace],
      Biform::Types.detect(options[:type]),
      options[:default],
      options[:nilify],
      options[:writeable],
      options[:readable],
      options[:prepopulator],
      options[:populator],
      Biform::Factory::Validator.new(@form.model_name, options[:validates]).build
    )

    attribute.default!

    attribute
  end
end
