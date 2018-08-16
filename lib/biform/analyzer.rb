class Biform::Analyzer
  attr_reader :set

  def initialize(parent: nil)
    @parent = parent
    @current = nil
    @set = Biform::Properties::Set.new
  end

  def property(name, options = nil, &block)
    options = options.to_h.merge(node_type: :property)

    @current = Biform::Properties::SetNode.new(parent: @parent, name: name, options: options)

    @set.append(@current)

    if block
      analyzer = Biform::Analyzer.new(parent: @current)
      analyzer.instance_eval(&block)

      @set.append(analyzer.set)
    end
  end

  def collection(name, options = nil, &block)
    options = options.to_h.merge(node_type: :collection)

    @current = Biform::Properties::SetNode.new(parent: @parent, name: name, options: options)

    @set.append(@current)

    if block
      analyzer = Biform::Analyzer.new(parent: @current)
      analyzer.instance_eval(&block)

      @set.append(analyzer.set)
    end
  end
end
