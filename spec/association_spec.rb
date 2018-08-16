require "spec_helper"

RSpec.describe "Association" do
  before do
    class Post < ActiveRecord::Base; end
    class User < ActiveRecord::Base
      has_one :post
    end

    if Object.constants.include?(:UserForm)
      Object.send(:remove_const, :UserForm)
    end
  end

  it "accept associated model" do
    class UserForm < Biform::Form
      property :post do
        property :title
        property :body
      end
    end

    form = UserForm.new(User.new)

    expect(form).to respond_to(:post)
    expect(form.post).to respond_to(:title)
    expect(form.post).to respond_to(:body)
  end

  it "accept form in associated model" do
    class UserForm < Biform::Form
      property :post do
        property :title
        property :body

        property :data, virtual: true do
          property :payload, virtual: true
        end
      end
    end

    form = UserForm.new(User.new)

    expect(form).to respond_to(:post)
    expect(form.post).to respond_to(:title)
    expect(form.post).to respond_to(:body)
    expect(form.post).to respond_to(:data)
    expect(form.post.data).to respond_to(:payload)
  end

  it "writes to associated attributes" do
    class UserForm < Biform::Form
      property :post do
        property :title
        property :body
      end
    end

    form = UserForm.new(User.new)
    form.post.title = "Good morning"
    form.post.body = "qwerty"

    expect(form.post.title).to eq("Good morning")
    expect(form.post.body).to eq("qwerty")
  end

  it "writes hash to associated form" do
    class UserForm < Biform::Form
      property :post do
        property :title
        property :body
      end
    end

    form = UserForm.new(User.new)

    form.post = {
      "title" => "Good morning",
      "body" => "qwerty",
    }

    expect(form.post.title).to eq("Good morning")
    expect(form.post.body).to eq("qwerty")

    form.post = { body: nil }

    expect(form.post.title).to eq("Good morning")
    expect(form.post.body).to eq(nil)

    form.post = {
      title: "Good morning",
      body: "qwerty",
    }

    expect(form.post.title).to eq("Good morning")
    expect(form.post.body).to eq("qwerty")
  end

  it "writes to association in association" do
    class UserForm < Biform::Form
      property :post do
        property :title
        property :body

        property :data, virtual: true do
          property :payload, virtual: true
        end
      end
    end

    form = UserForm.new(User.new)

    form.post = {
      "title" => "Good morning",
    }

    expect(form.post.title).to eq("Good morning")
    expect(form.post.data.payload).to eq(nil)

    form.post = {
      "title" => "Good morning",
      "data" => {
        "payload" => nil,
      },
    }

    expect(form.post.title).to eq("Good morning")
    expect(form.post.data.payload).to eq(nil)

    form.post = {
      "title" => "Good morning",
      "data" => {
        "payload" => "123",
      },
    }

    expect(form.post.title).to eq("Good morning")
    expect(form.post.data.payload).to eq("123")
  end
end
