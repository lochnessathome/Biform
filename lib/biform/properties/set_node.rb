class Biform::Properties::SetNode
  attr_reader :parent, :name, :options

  def initialize(parent: nil, name:, options:)
    @parent = parent
    @name = name
    @options = options || {}
  end

  def chain
    buf = [@name]

    if @parent
      buf = @parent.chain + buf
    end

    buf
  end
end
