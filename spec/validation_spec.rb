require "spec_helper"

RSpec.describe "Validation" do
  before do
    class Post < ActiveRecord::Base; end
    class User < ActiveRecord::Base
      has_one :post
    end

    if Object.constants.include?(:UserForm)
      Object.send(:remove_const, :UserForm)
    end
  end

  it "presence - plain" do
    class UserForm < Biform::Form
      property :name, validates: { presence: true }
    end

    form = UserForm.new(User.new)

    expect(form.valid?).to be false

    form.name = "John"

    expect(form.valid?).to be true
  end

  it "presence - association" do
    class UserForm < Biform::Form
      property :name, validates: { presence: true }

      property :post do
        property :body, validates: { presence: true }
      end
    end

    form = UserForm.new(User.new)
    form.name = "John"

    expect(form.valid?).to be false

    form.post.body = "TEXT"

    expect(form.valid?).to be true
  end

  it "presence - collection" do
    class UserForm < Biform::Form
      property :name, validates: { presence: true }

      collection :countries, virtual: true do
        property :name, virtual: true, validates: { presence: true }
      end
    end

    form = UserForm.new(User.new)
    form.name = "John"

    expect(form.valid?).to be true

    form.countries = [{ name: nil }]

    expect(form.valid?).to be false

    form = UserForm.new(User.new)
    form.name = "John"

    expect(form.valid?).to be true

    form.countries = [{ name: "Peru" }]

    expect(form.valid?).to be true
  end

  it "errors - plain" do
    class UserForm < Biform::Form
      property :name, validates: { presence: true }
    end

    form = UserForm.new(User.new)

    expect(form).to respond_to(:errors)
    expect(form.errors).to respond_to(:messages)
    expect(form.errors.messages[:name].present?).to eq(true)

    form.name = "John"

    expect(form).to respond_to(:errors)
    expect(form.errors).to respond_to(:messages)
    expect(form.errors.messages[:name]).to eq([])
  end

  it "errors - association" do
    class UserForm < Biform::Form
      property :name, validates: { presence: true }

      property :post do
        property :body, validates: { presence: true }
      end
    end

    form = UserForm.new(User.new)
    form.name = "John"

    expect(form.errors.messages[:post].present?).to eq(true)

    form.post.body = "TEXT"

    expect(form.errors.messages[:post]).to eq([])
  end

  it "errors - collection" do
    class UserForm < Biform::Form
      property :name, validates: { presence: true }

      collection :countries, virtual: true do
        property :name, virtual: true, validates: { presence: true }
      end
    end

    form = UserForm.new(User.new)
    form.name = "John"

    expect(form.errors.messages[:countries]).to eq([])

    form.countries = [{ name: nil }]

    expect(form.errors.messages[:countries].present?).to eq(true)

    form = UserForm.new(User.new)
    form.name = "John"

    form.countries = [{ name: "Peru" }]

    expect(form.errors.messages[:countries]).to eq([])
  end

  it "length" do
    class UserForm < Biform::Form
      property :name, validates: { length: { in: 1..15 } }
    end

    form = UserForm.new(User.new)

    expect(form.valid?).to be false

    form.name = "John"

    expect(form.valid?).to be true
  end

  it "format" do
    class UserForm < Biform::Form
      property :name, validates: { format: /\A[a-z]+\z/i }
    end

    form = UserForm.new(User.new)

    expect(form.valid?).to be false

    form.name = "John"

    expect(form.valid?).to be true
  end
end
