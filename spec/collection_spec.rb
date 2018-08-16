require "spec_helper"

RSpec.describe "Collection" do
  before do
    class Post < ActiveRecord::Base; end
    class User < ActiveRecord::Base
      has_many :posts
    end

    if Object.constants.include?(:UserForm)
      Object.send(:remove_const, :UserForm)
    end
  end

  it "accept associated collection" do
    class UserForm < Biform::Form
      collection :posts do
        property :title
        property :body
      end
    end

    form = UserForm.new(User.new)

    expect(form).to respond_to(:posts)
    expect(form.posts).to respond_to(:to_a)
    expect(form.posts).to respond_to(:first)
  end

  it "writes to associated collection" do
    class UserForm < Biform::Form
      collection :posts do
        property :title
        property :body
      end
    end

    form = UserForm.new(User.new)

    form.posts = [{
      "title" => "Good afternoon",
      "body" => "qwerty",
    }]

    expect(form.posts.size).to eq(1)
    expect(form.posts[0].title).to eq("Good afternoon")
    expect(form.posts[0].body).to eq("qwerty")

    form.posts = []

    expect(form.posts.size).to eq(1)
    expect(form.posts[0].title).to eq("Good afternoon")
    expect(form.posts[0].body).to eq("qwerty")

    form.posts = [{}]

    expect(form.posts.size).to eq(1)
    expect(form.posts[0].title).to eq("Good afternoon")
    expect(form.posts[0].body).to eq("qwerty")
  end

  it "accept form in associated collection" do
    class UserForm < Biform::Form
      collection :posts do
        property :title
        property :body

        property :data, virtual: true do
          property :payload, virtual: true
        end
      end
    end

    form = UserForm.new(User.new)

    form.posts = [{
      "data" => {
        "payload" => "123",
      },
    }]

    expect(form.posts[0].data.payload).to eq("123")
  end

  it "accepts collection inside collection" do
    class UserForm < Biform::Form
      collection :posts do
        property :title

        collection :languages, virtual: true do
          property :country, virtual: true do
            property :name, virtual: true
          end

          property :label, virtual: true
        end
      end
    end

    form = UserForm.new(User.new)
    form.posts = [{
      "title" => "Post #1",
      "languages" => [
        {
          "country" => {
            "name" => "Russia",
          },
          "label" => "russian",
        },
        {
          "country" => {
            "name" => "Spain",
          },
          "label" => "spanish",
        },
      ],
    }]

    expect(form.posts.size).to eq(1)
    post = form.posts[0]
    expect(post.title).to eq("Post #1")
    expect(post.languages.size).to eq(2)
    expect(post.languages[0].country.name).to eq("Russia")
    expect(post.languages[0].label).to eq("russian")
    expect(post.languages[1].country.name).to eq("Spain")
    expect(post.languages[1].label).to eq("spanish")
  end
end
