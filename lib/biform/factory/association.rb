class Biform::Factory::Association
  DEFAULT_OPTS = { virtual: false }.freeze

  def initialize(property, branch, form)
    @property = property
    @name = property.name

    options = DEFAULT_OPTS.merge(property.options)
    @virtual = options[:virtual]

    @branch = branch
    @form = form
  end

  def build
    association = if @virtual
                    build_virtual
                  else
                    if @form.model && @form.model.associations.keys.include?(@name)
                      build_real
                    else
                      build_virtual
                    end
                  end

    @form.instance_variable_set("@associations", @form.associations.merge(@name => association))

    @form.instance_eval "def #{@name}; @associations[:#{@name}].get; end;"

    @form.instance_eval "def #{@name}=(value); @associations[:#{@name}].set(value); end;"
  end

  private

  def build_real
    association = @form.model.associations[@name]

    form = Biform::Factory::Common.build_real_form(
      association[:value] || association[:template].call,
      proc { nil },
      @branch.shift
    )

    Biform::Components::Association.new(form, association[:klass])
  end

  def build_virtual
    form = Biform::Factory::Common.build_virtual_form(@name, @branch.shift)

    Biform::Components::Association.new(form, :virtual)
  end
end
