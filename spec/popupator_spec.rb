require "spec_helper"

RSpec.describe "Populator" do
  before do
    class User < ActiveRecord::Base; end

    if Object.constants.include?(:UserForm)
      Object.send(:remove_const, :UserForm)
    end
  end

  it "attribute - manual" do
    class UserForm < Biform::Form
      property :name
      property :age, virtual: true, populator: proc { |options| self.age = options[:age] }
    end

    form = UserForm.new(User.new)
    form.populate!(age: 20)

    expect(form.age).to eq(20)
  end

  it "association - manual" do
    class UserForm < Biform::Form
      property :post do
        property :title
        property :body, populator: proc { self.body = "Text is #{self.title}" }
      end
    end

    form = UserForm.new(User.new)
    form.post.title = "..."
    form.populate!

    expect(form.post.body).to eq("Text is ...")
  end

  it "collection - manual" do
    class UserForm < Biform::Form
      collection :posts, virtual: true do
        property :title
        property :body, populator: proc { self.body = "Text is #{self.title}" }
      end
    end

    form = UserForm.new(User.new)
    form.posts = [
      { title: "#1" },
      { title: "#2", body: "..." },
    ]
    form.populate!

    expect(form.posts[0].body).to eq("Text is #1")
    expect(form.posts[1].body).to eq("Text is #2")
  end

  it "with validate" do
    class UserForm < Biform::Form
      property :name
      property :age, virtual: true, populator: proc { |options| self.age = options[:age].to_i + 1 }
    end

    form = UserForm.new(User.new)
    form.validate(age: 20)

    expect(form.age).to eq(21)
  end
end
