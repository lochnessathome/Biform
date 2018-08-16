require "spec_helper"

RSpec.describe "Save" do
  before do
    class Post < ActiveRecord::Base
      validates_presence_of :body
    end
    class User < ActiveRecord::Base
      has_one :post
    end

    if Object.constants.include?(:UserForm)
      Object.send(:remove_const, :UserForm)
    end
  end

  after do
    if Object.constants.include?(:Post)
      Object.send(:remove_const, :Post)
    end
  end

  it "attribute - valid form" do
    class UserForm < Biform::Form
      property :name, validates: { presence: true }
    end

    user = User.new
    form = UserForm.new(user)

    form.name = "John"

    expect(form.save).to eq(true)
    expect(user.persisted?).to eq(true)
    expect(user.reload.name).to eq("John")
  end

  it "attribute - invalid form" do
    class UserForm < Biform::Form
      property :name, validates: { presence: true }
    end

    user = User.new
    form = UserForm.new(user)

    expect(form.save).to eq(false)
    expect(user.persisted?).to eq(false)
  end

  it "nested - valid model" do
    class UserForm < Biform::Form
      property :name

      property :post do
        property :body
      end
    end

    user = User.new
    form = UserForm.new(user)
    form.name = "John"
    form.post.body = "..."

    expect(form.save).to eq(true)
    expect(user.persisted?).to eq(true)
    expect(user.reload.name).to eq("John")
    expect(user.post.persisted?).to eq(true)
    expect(user.post.reload.body).to eq("...")
  end

  it "nested - invalid model" do
    class UserForm < Biform::Form
      property :name

      property :post do
        property :body
      end
    end

    user = User.new
    form = UserForm.new(user)
    form.name = "John"
    form.post.body = ""

    expect(form.save).to eq(false)
    expect(user.persisted?).to eq(false)
    expect(user.post.persisted?).to eq(false)
  end
end
