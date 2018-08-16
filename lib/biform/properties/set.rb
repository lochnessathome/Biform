class Biform::Properties::Set
  attr_reader :nodes

  def initialize
    @nodes = []
  end

  def append(node)
    if node.instance_of?(Biform::Properties::Set)
      @nodes += node.nodes
    elsif node.instance_of?(Biform::Properties::SetNode)
      @nodes << node
    end
  end
end
