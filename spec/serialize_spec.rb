require "spec_helper"

RSpec.describe "Serialize" do
  before do
    class Post < ActiveRecord::Base; end
    class User < ActiveRecord::Base
      has_one :post
    end

    if Object.constants.include?(:UserForm)
      Object.send(:remove_const, :UserForm)
    end
  end

  it "attribute" do
    class UserForm < Biform::Form
      property :name
    end

    user = User.new
    form = UserForm.new(user)

    form.name = "John"

    expect(form.serialize).to eq(name: "John")
  end

  it "association" do
    class UserForm < Biform::Form
      property :name

      property :post do
        property :title
        property :length, virtual: true
      end
    end

    user = User.new
    form = UserForm.new(user)

    form.name = "John"
    form.post.title = "Post #1"
    form.post.length = 7

    expect(form.serialize).to eq(name: "John", post: { title: "Post #1", length: 7 })
  end

  it "collection" do
    class UserForm < Biform::Form
      property :name

      collection :posts, virtual: true do
        property :title, virtual: true
        property :length, virtual: true
      end
    end

    user = User.new
    form = UserForm.new(user)

    form.name = "John"
    form.posts = [
      { title: "Post #1", length: 7 },
    ]

    expect(form.serialize).to eq(name: "John", posts: [{ title: "Post #1", length: 7 }])
  end
end
