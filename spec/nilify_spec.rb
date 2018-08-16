require "spec_helper"

RSpec.describe "Nilify" do
  before do
    class User < ActiveRecord::Base; end

    if Object.constants.include?(:UserForm)
      Object.send(:remove_const, :UserForm)
    end
  end

  it "empty strings - enabled" do
    class UserForm < Biform::Form
      property :name, nilify: true
    end

    form = UserForm.new(User.new)
    form.name = ""

    expect(form.name).to eq(nil)
  end

  it "empty strings - disabled" do
    class UserForm < Biform::Form
      property :name, nilify: false
    end

    form = UserForm.new(User.new)
    form.name = ""

    expect(form.name).to eq("")
  end

  it "empty int - enabled" do
    class UserForm < Biform::Form
      property :id, nilify: true
    end

    form = UserForm.new(User.new)
    form.id = ""

    expect(form.id).to eq(nil)
  end

  it "empty int - disabled" do
    class UserForm < Biform::Form
      property :id, nilify: false
    end

    form = UserForm.new(User.new)
    form.id = ""

    expect(form.id).to eq(nil)
  end
end
