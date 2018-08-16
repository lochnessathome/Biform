class Biform::Factory::Form
  def initialize(form)
    @form = form
  end

  def build
    @form.properties.roots.each do |property|
      branch = @form.properties.branch(property.chain)

      if property.options[:node_type] == :property
        if branch.nodes.size == 1
          Biform::Factory::Attribute.new(property, @form).build
        else
          Biform::Factory::Association.new(property, branch, @form).build
        end
      elsif property.options[:node_type] == :collection
        Biform::Factory::Collection.new(property, branch, @form).build
      end
    end
  end
end
