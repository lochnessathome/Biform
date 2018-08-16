class Biform::Form < Biform::Components::RealForm
  Types = Biform::Types

  def initialize(record)
    super(record)

    unless self.class.class_variables.include?(:@@properties_set)
      self.class.class_variable_set(:@@properties_set, Biform::Properties::Set.new)
    end

    unless self.class.class_variables.include?(:@@properties_tree)
      processor = Biform::Preprocessor.new(self)

      processor.expand_nested_forms
      processor.mark_namespace
      processor.clear_options

      self.class.class_variable_set(:@@properties_tree, Biform::Properties::Tree.new)

      self.class.class_variable_get(:@@properties_set).nodes.each do |node|
        self.class.class_variable_get(:@@properties_tree).append(node.name, node.chain, node.options)
      end
    end

    instance_eval "def properties; self.class.class_variable_get(:@@properties_tree); end"

    Biform::Factory::Form.new(self).build
  end

  def self.property(name, options = nil, &block)
    options = options.to_h.merge(node_type: :property)

    unless self.class_variables.include?(:@@properties_set)
      self.class_variable_set(:@@properties_set, Biform::Properties::Set.new)
    end

    analyzer = Biform::Analyzer.new(parent: nil)
    analyzer.property(name, options, &block)

    analyzer.set.append(self.class_variable_get(:@@properties_set))

    self.class_variable_set(:@@properties_set, analyzer.set)
  end

  def self.collection(name, options = nil, &block)
    options = options.to_h.merge(node_type: :collection)

    unless self.class_variables.include?(:@@properties_set)
      self.class_variable_set(:@@properties_set, Biform::Properties::Set.new)
    end

    analyzer = Biform::Analyzer.new(parent: nil)
    analyzer.collection(name, options, &block)

    analyzer.set.append(self.class_variable_get(:@@properties_set))

    self.class_variable_set(:@@properties_set, analyzer.set)
  end

  def validate(parameters)
    return nil unless parameters.instance_of?(Hash)

    permitted = parameters.keys & keys

    parameters.slice(*permitted).each do |key, val|
      self.send("#{key}=", val)
    end

    populate!(parameters)

    valid?
  end
end
