class Biform::Model::Sequel
  def initialize(record)
    @record = record
  end

  def attributes
    buf = {}

    @record.db_schema.each do |key, val|
      buf[key] = {
        value: @record[key],
        type: val[:type],
        default: val[:default],
      }
    end

    buf
  end

  def associations
    buf = {}
    return buf

    # TODO: научиться с ассоциациям one-to-one когда оба объекта не сохранены в базу
    #
    # @record.class.associations.each do |association|
    #   buf[association] = {
    #     value: @record.send(association),
    #     klass: @record.instance_eval("#{association}_dataset").model
    #   }
    # end
    #
    # buf
  end

  def sync(attribute, value)
    return nil unless attributes.keys.include?(attribute)

    @record.send("#{attribute}=", value)
  end

  def save
    @record.save
  end

  def to_key
    id ? [id] : nil
  end

  def to_param
    id ? id.to_s : nil
  end

  def id
    @record.id
  end

  def persisted?
    @record.exists?
  end
end
