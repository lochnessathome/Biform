class Biform::Components::Association
  attr_accessor :form, :klass

  delegate :prepopulate!, :populate!, :valid?, :sync, :save, :serialize, to: :form

  def initialize(form, klass)
    @form = form
    @klass = klass
  end

  def get
    @form
  end

  # требую присылать id если запись сохранена
  def set(value)
    return nil unless value.instance_of?(Hash)

    value.symbolize_keys!

    if @form.id.nil? || (@form.id.present? && @form.id == value[:id])
      keys = @form.keys & value.keys

      value.slice(*keys).each do |key, val|
        @form.send("#{key}=", val)
      end
    end
  end
end
