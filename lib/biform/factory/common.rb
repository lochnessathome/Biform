class Biform::Factory::Common
  class << self
    def build_virtual_form(name, properties)
      form = Biform::Components::VirtualForm.new(name)

      form.instance_variable_set(:@properties_tree, properties)
      form.instance_eval "def properties; self.instance_variable_get(:@properties_tree); end"

      Biform::Factory::Form.new(form).build

      form
    end

    def build_real_form(record, template, properties)
      form = Biform::Components::RealForm.new(record)

      form.instance_variable_set(:@properties_tree, properties)
      form.instance_eval "def properties; self.instance_variable_get(:@properties_tree); end"

      form.model.instance_variable_set(:@template, template)
      form.model.instance_eval "def template; @template.call; end"

      Biform::Factory::Form.new(form).build

      form
    end
  end
end
