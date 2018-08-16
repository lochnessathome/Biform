require "spec_helper"

RSpec.describe "Property" do
  before do
    class User < ActiveRecord::Base; end

    if Object.constants.include?(:UserForm)
      Object.send(:remove_const, :UserForm)
    end
  end

  it "accept model attributes" do
    class UserForm < Biform::Form
      property :id
      property :name
    end

    form = UserForm.new(User.new)

    expect(form).to respond_to(:id)
    expect(form).to respond_to(:name)
  end

  it "reads model data" do
    class UserForm < Biform::Form
      property :id
      property :name
    end

    record = User.create(id: 1, name: "John")

    form = UserForm.new(record)

    expect(form.id).to eq(1)
    expect(form.name).to eq("John")
  end

  it "accepts virtual attributes" do
    class UserForm < Biform::Form
      property :age, virtual: true
    end

    form = UserForm.new(User.new)

    expect(form).to respond_to(:age)
  end

  it "accept nested attributes #1" do
    class UserForm < Biform::Form
      property :id
      property :name

      property :data, virtual: true do
        property :country, virtual: true
        property :city, virtual: true
      end
    end

    form = UserForm.new(User.new)

    expect(form).to respond_to(:id)
    expect(form).to respond_to(:name)

    expect(form).to respond_to(:data)
    expect(form.data).to respond_to(:country)
    expect(form.data).to respond_to(:city)
  end

  it "accept nested attributes #2" do
    class DataForm < Biform::Form
      property :country, virtual: true
      property :city, virtual: true
    end

    class UserForm < Biform::Form
      property :id
      property :name

      property :data, virtual: true, form: DataForm
    end

    form = UserForm.new(User.new)

    expect(form).to respond_to(:id)
    expect(form).to respond_to(:name)

    expect(form).to respond_to(:data)
    expect(form.data).to respond_to(:country)
    expect(form.data).to respond_to(:city)
  end
end
