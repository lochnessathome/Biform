class Biform::Properties::TreeNode
  attr_reader :name, :chain, :options

  def initialize(name, chain, options)
    @name = name
    @chain = chain
    @options = options
  end
end
