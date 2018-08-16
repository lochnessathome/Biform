require "spec_helper"

RSpec.describe "Type" do
  before do
    class User < ActiveRecord::Base; end

    if Object.constants.include?(:UserForm)
      Object.send(:remove_const, :UserForm)
    end
  end

  it "accepts strict type data" do
    class UserForm < Biform::Form
      property :age, virtual: true, type: Types::Strict::Int
    end

    form = UserForm.new(User.new)
    form.age = 25

    expect(form.age).to eq(25)
  end

  it "accepts coercible type data" do
    class UserForm < Biform::Form
      property :age, virtual: true, type: Types::Coercible::Int
    end

    form = UserForm.new(User.new)
    form.age = "25"

    expect(form.age).to eq(25)
  end

  it "rejects incorrect type data" do
    class UserForm < Biform::Form
      property :age, virtual: true, type: Types::Strict::Int
    end

    form = UserForm.new(User.new)
    form.age = "25"

    expect(form.age).to eq(nil)
  end

  it "accepts any data with undefined type" do
    class UserForm < Biform::Form
      property :age, virtual: true
    end

    form = UserForm.new(User.new)
    obj = Class.new
    form.age = obj

    expect(form.age).to eq(obj)
  end

  it "detects attribute type" do
    class UserForm < Biform::Form
      property :id # integer in db schema
    end

    form = UserForm.new(User.new)
    form.id = "1"

    expect(form.id).to eq(1)
  end
end
