require "spec_helper"

RSpec.describe "Validate" do
  before do
    class Post < ActiveRecord::Base; end
    class User < ActiveRecord::Base
      has_one :post
    end

    if Object.constants.include?(:UserForm)
      Object.send(:remove_const, :UserForm)
    end
  end

  it "no check - plain" do
    class UserForm < Biform::Form
      property :name
    end

    form = UserForm.new(User.new)
    ret = form.validate(name: "John")

    expect(form.valid?).to be true
    expect(ret).to be true
    expect(form.name).to eq("John")
  end

  it "no check - nested" do
    class UserForm < Biform::Form
      property :name

      property :post do
        property :body
      end
    end

    form = UserForm.new(User.new)
    ret = form.validate(name: "John")

    expect(form.valid?).to be true
    expect(ret).to be true
    expect(form.name).to eq("John")

    ret = form.validate(post: { body: "John" })

    expect(form.valid?).to be true
    expect(ret).to be true
    expect(form.name).to eq("John")
    expect(form.post.body).to eq("John")

    ret = form.validate(name: nil)

    expect(form.valid?).to be true
    expect(ret).to be true
    expect(form.name).to eq(nil)
    expect(form.post.body).to eq("John")
  end

  it "check - plain" do
    class UserForm < Biform::Form
      property :name, validates: { presence: true }
    end

    form = UserForm.new(User.new)
    ret = form.validate({})

    expect(form.valid?).to be false
    expect(ret).to be false
    expect(form.name).to eq(nil)

    ret = form.validate(name: "")

    expect(form.valid?).to be false
    expect(ret).to be false
    expect(form.name).to eq("")

    ret = form.validate(name: "John")

    expect(form.valid?).to be true
    expect(ret).to be true
    expect(form.name).to eq("John")
  end

  it "check - nested" do
    class UserForm < Biform::Form
      property :name, validates: { presence: true }

      property :post do
        property :body, validates: { presence: true }
      end
    end

    form = UserForm.new(User.new)
    ret = form.validate(name: "John")

    expect(form.valid?).to be false
    expect(ret).to be false
    expect(form.post.body).to eq(nil)

    ret = form.validate(post: { body: "TEXT" })

    expect(form.valid?).to be true
    expect(ret).to be true
    expect(form.post.body).to eq("TEXT")
  end
end
