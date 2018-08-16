require "spec_helper"

RSpec.describe "Prepopulator" do
  before do
    class User < ActiveRecord::Base; end

    if Object.constants.include?(:UserForm)
      Object.send(:remove_const, :UserForm)
    end
  end

  it "one attribute - proc" do
    class UserForm < Biform::Form
      property :name, prepopulator: proc { self.name = "Johan" }
    end

    form = UserForm.new(User.new)
    form.prepopulate!

    expect(form.name).to eq("Johan")
  end

  it "one attribute - proc - options" do
    class UserForm < Biform::Form
      property :name, prepopulator: proc { |options| self.name = options[:name] }
    end

    form = UserForm.new(User.new)
    form.prepopulate!(name: "Johan")

    expect(form.name).to eq("Johan")
  end

  it "one attribute - method" do
    class UserForm < Biform::Form
      property :name, prepopulator: :fill_name

      def fill_name
        self.name = "Johan"
      end
    end

    form = UserForm.new(User.new)
    form.prepopulate!

    expect(form.name).to eq("Johan")
  end

  it "one attribute - method - options" do
    class UserForm < Biform::Form
      property :name, prepopulator: :fill_name

      def fill_name(options)
        self.name = options[:name]
      end
    end

    form = UserForm.new(User.new)
    form.prepopulate!(name: "Johan")

    expect(form.name).to eq("Johan")
  end

  it "two attributes - proc" do
    class UserForm < Biform::Form
      property :id, default: 1
      property :name, prepopulator: proc { self.name = "User ##{self.id}" }
    end

    form = UserForm.new(User.new)
    form.prepopulate!

    expect(form.name).to eq("User #1")
  end

  # rubocop:disable Style/Semicolon
  it "two attributes - proc - options" do
    class UserForm < Biform::Form
      property :id
      property :name, prepopulator: proc { |options| self.id = options[:id]; self.name = "User ##{self.id}" }
    end

    form = UserForm.new(User.new)
    form.prepopulate!(id: 0)

    expect(form.id).to eq(0)
    expect(form.name).to eq("User #0")
  end
  # rubocop:enable Style/Semicolon

  it "association - proc" do
    class UserForm < Biform::Form
      property :post do
        property :body, prepopulator: proc { self.body = "..." }
      end
    end

    form = UserForm.new(User.new)
    form.prepopulate!

    expect(form.post.body).to eq("...")
  end

  it "collection - proc" do
    class UserForm < Biform::Form
      collection :posts, virtual: true do
        property :title
        property :body, prepopulator: proc { self.body = "Text is #{self.title}" }
      end
    end

    form = UserForm.new(User.new)
    form.posts = [
      { title: "..." },
    ]
    form.prepopulate!

    expect(form.posts[0].body).to eq("Text is ...")
  end
end
