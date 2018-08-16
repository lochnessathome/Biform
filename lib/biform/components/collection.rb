class Biform::Components::Collection
  attr_accessor :form, :klass

  def initialize(form, klass)
    @form = form
    @klass = klass

    @list = []
  end

  def get
    @list
  end

  # требую присылать id если запись сохранена
  def set(list)
    return nil unless list.instance_of?(Array)

    list.each do |attrs|
      next if attrs.blank?

      attrs.symbolize_keys!

      if attrs[:id] && form = @list.find { |f| f.id == attrs[:id] }
        update_form(form, attrs)
      else
        @list << build_form(attrs)
      end
    end

    @list.compact!
  end

  def prepopulate!(options)
    @list.each { |form| form.prepopulate!(options) }
  end

  def populate!(options)
    @list.each { |form| form.populate!(options) }
  end

  def valid?
    return false if @list.any? { |form| !form.valid? }

    true
  end

  def sync
    @list.each(&:sync)
  end

  def serialize
    @list.map(&:serialize)
  end

  def save
    @list.each(&:save)
  end

  private

  def build_form(attrs)
    return nil unless attrs.instance_of?(Hash)

    attrs.symbolize_keys!

    if @form.class == Biform::Components::VirtualForm
      form = Biform::Factory::Common.build_virtual_form(@form.instance_variable_get(:@name), @form.properties)
    else
      form = Biform::Factory::Common.build_real_form(
        @form.model.template,
        proc { nil },
        @form.properties
      )
    end

    keys = form.keys & attrs.keys

    attrs.slice(*keys).each do |key, val|
      form.send("#{key}=", val)
    end

    form
  end

  def update_form(form, attrs)
    return nil unless attrs.instance_of?(Hash)

    attrs.symbolize_keys!

    keys = form.keys & attrs.keys

    attrs.slice(*keys).each do |key, val|
      form.send("#{key}=", val)
    end

    form
  end
end
