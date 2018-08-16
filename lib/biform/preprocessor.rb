class Biform::Preprocessor
  def initialize(form)
    @form = form
  end

  def expand_nested_forms
    set = flatten_nodes(Biform::Properties::Set.new, @form.class.class_variable_get(:@@properties_set).nodes)

    @form.class.class_variable_set(:@@properties_set, set)
  end

  def mark_namespace
    @form.class.class_variable_get(:@@properties_set).nodes.each do |node|
      namespace = namespace_of(node) || @form.class

      node.instance_variable_set(:@options, node.options.merge(namespace: namespace))
    end
  end

  def clear_options
    @form.class.class_variable_get(:@@properties_set).nodes.each do |node|
      node.options.delete(:form)
    end
  end

  private

  def flatten_nodes(set, nodes, parent = nil)
    nodes.each do |node|
      if parent && node.parent.nil?
        node.instance_variable_set(:@parent, parent)
      end

      set.append(node)

      if nested = node.options[:form]
        if nested.superclass == Biform::Form
          set = flatten_nodes(set, nested.class_variable_get(:@@properties_set).nodes, node)
        end
      end
    end

    set
  end

  def namespace_of(node)
    if node.options[:form]
      node.options[:form]
    elsif node.parent
      namespace_of(node.parent)
    end
  end
end
