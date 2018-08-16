require "spec_helper"

RSpec.describe "Biform::Form" do
  before do
    if Object.constants.include?(:UserForm)
      Object.send(:remove_const, :UserForm)
    end
  end

  it "module loads" do
    expect(Biform::Form.to_s).to eq("Biform::Form")
  end

  it "builds a form" do
    class User < ActiveRecord::Base; end
    class UserForm < Biform::Form
      property :name
    end

    form = UserForm.new(User.new)

    expect(form).to be_truthy
    expect(form).to be_kind_of(Biform::Form)
  end

  it "builds an empty form" do
    class User < ActiveRecord::Base; end
    class UserForm < Biform::Form; end

    form = UserForm.new(User.new)

    expect(form).to be_truthy
    expect(form).to be_kind_of(Biform::Form)
  end
end
