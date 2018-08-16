class Biform::Model::Activerecord
  def initialize(record)
    @record = record
  end

  def attributes
    buf = {}

    @record.class.columns_hash.each do |key, val|
      buf[key.to_sym] = {
        value: @record[key],
        type: val.type,
        default: val.default,
      }
    end

    buf
  end

  def associations
    buf = {}

    @record.class.reflect_on_all_associations.each do |association|
      buf[association.name] = {
        value: value_for(association.name),
        template: template_for(association.name),
        klass: association.klass,
      }
    end

    buf
  end

  def sync(attribute, value)
    return nil unless attributes.keys.include?(attribute)

    @record.send("#{attribute}=", value)
  end

  def save
    @record.save!
  end

  def to_key
    @record.to_key
  end

  def to_param
    @record.to_param
  end

  def id
    @record.id
  end

  def persisted?
    @record.persisted?
  end

  private

  def template_for(name)
    if @record.respond_to?("build_#{name}") # one-to-many
      proc do
        @record.instance_eval("build_#{name}")
      end
    elsif @record.respond_to?(name) && @record.instance_eval("#{name}").respond_to?("build") # many-to-many
      proc do
        @record.instance_eval("#{name}.build")
      end
    end
  end

  def value_for(name)
    if @record.respond_to?("reload_#{name}") # one-to-many
      @record.instance_eval("reload_#{name}")
    elsif @record.send(name) && @record.instance_eval("#{name}").respond_to?("reload") # many-to-many
      @record.instance_eval("#{name}.reload").to_a
    end
  end
end
