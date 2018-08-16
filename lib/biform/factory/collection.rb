class Biform::Factory::Collection
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
    collection = if @virtual
                   build_virtual
                 else
                   if @form.model && @form.model.associations.keys.include?(@name)
                     build_real
                   else
                     build_virtual
                   end
                 end

    @form.instance_variable_set("@collections", @form.collections.merge(@name => collection))

    @form.instance_eval "def #{@name}; @collections[:#{@name}].get; end;"

    @form.instance_eval "def #{@name}=(value); @collections[:#{@name}].set(value); end;"
  end

  private

  def build_real
    association = @form.model.associations[@name]

    form = Biform::Factory::Common.build_real_form(
      association[:klass].new,
      association[:template],
      @branch.shift
    )

    collection = Biform::Components::Collection.new(form, association[:klass])

    list = association[:value].map do |record|
      Biform::Factory::Common.build_real_form(
        record,
        proc { nil },
        @branch.shift
      )
    end

    collection.instance_variable_set(:@list, list)

    collection
  end

  def build_virtual
    form = Biform::Factory::Common.build_virtual_form(@name, @branch.shift)

    Biform::Components::Collection.new(form, :virtual)
  end
end
