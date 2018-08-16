class Biform::Components::Attribute
  attr_reader :type, :virtual, :default # FIXME: это нужно?
  attr_reader :errors

  def initialize(virtual, namespace, type, default, nilify, writeable, readable, prepopulator, populator, validator)
    @value = nil
    @errors = []

    @virtual = virtual
    @namespace = namespace
    @type = type
    @default = default
    @nilify = nilify
    @writeable = writeable
    @readable = readable
    @prepopulator = prepopulator
    @populator = populator
    @validator = validator
  end

  def get
    @value
  end

  def set(value)
    if value.nil?
      @value = nil
    else
      begin
        @value = @type[value]
      rescue
        @value = nil
      end
    end

    nilify! if @nilify
    validate! if @validator
  end

  def default!
    if @default
      if @default.instance_of?(Proc)
        @value = @default.call
      else
        @value = @default
      end
    end

    validate! if @validator
  end

  def prepopulate!(options, form)
    return unless @prepopulator

    if @prepopulator.instance_of?(::Symbol) && @namespace.instance_methods.include?(@prepopulator)
      context_for(form, @prepopulator).call(options)
      remove_context(@prepopulator)
    elsif @prepopulator.instance_of?(::Proc)
      form.instance_exec(options, &@prepopulator)
    end
  end

  def populate!(options, form)
    return unless @populator

    if @populator.instance_of?(::Symbol) && @namespace.instance_methods.include?(@populator)
      context_for(form, @populator).call(options)
      remove_context(@populator)
    elsif @populator.instance_of?(::Proc)
      form.instance_exec(options, &@populator)
    end
  end

  def valid?
    @errors.empty?
  end

  private

  def nilify!
    if @value == ""
      @value = nil
    end
  end

  def validate!
    validation = @validator.new(@value)

    if validation.valid?
      @errors = []
    else
      @errors = validation.messages
    end
  end

  def context_for(form, method)
    context_class_name = method.to_s.camelize + "Context"
    method_has_params = @namespace.instance_method(method).arity.positive?

    eval %Q{
              class #{context_class_name} < #{@namespace}
                def initialize(context)
                  @context = context
                end

                def method_missing(name, *args, &block)
                  @context.send(name, *args, &block)
                end

                def call(*args)
                  #{method}#{'(*args)' if method_has_params}
                end

                def #{method}(*args)
                  super(*args)
                end
              end
            }

    context_class = eval(context_class_name)

    context_class.new(form)
  end

  def remove_context(method)
    context_class_name = method.to_s.camelize + "Context"

    if self.class.constants.include?(context_class_name.to_sym)
      self.class.send(:remove_const, context_class_name.to_sym)
    end
  end
end
