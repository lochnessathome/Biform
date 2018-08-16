class Biform::Properties::Tree
  attr_reader :nodes

  def initialize
    @nodes = []
  end

  def append(name, chain, options)
    @nodes << Biform::Properties::TreeNode.new(name, chain, options)
  end

  def branch(prefix = [])
    buf = Biform::Properties::Tree.new

    @nodes.each do |node|
      if node.chain.join(" ").start_with?(prefix.join(" "))
        chain = if prefix.size.positive?
                  node.chain[(prefix.size - 1)..-1]
                else
                  node.chain
                end

        buf.append(node.name, chain, node.options)
      end
    end

    buf
  end

  def roots
    @nodes.select { |node| node.chain.size == 1 }
  end

  def shift
    buf = Biform::Properties::Tree.new

    @nodes.each do |node|
      if node.chain.size > 1
        buf.append(node.name, node.chain[1..-1], node.options)
      end
    end

    buf
  end
end
