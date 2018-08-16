require "spec_helper"

RSpec.describe "Sync" do
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
    form.sync

    expect(user.name).to eq("John")
  end

  it "association - new record" do
    class UserForm < Biform::Form
      property :post do
        property :body
      end
    end

    user = User.new
    form = UserForm.new(user)

    form.post.body = "TEXT"
    form.sync

    expect(user.post.body).to eq("TEXT")
  end

  it "association - saved record" do
    class UserForm < Biform::Form
      property :post do
        property :body
      end
    end

    user = User.new(name: "John")
    user.save
    user.post = Post.new(title: "Diary")
    user.post.save

    form = UserForm.new(user)

    form.post.body = "Memories"
    form.sync

    expect(user.post.body).to eq("Memories")
  end

  it "collection - new record" do
    if Object.constants.include?(:User)
      Object.send(:remove_const, :User)
    end

    class User < ActiveRecord::Base
      has_many :posts
    end

    class UserForm < Biform::Form
      collection :posts do
        property :body
      end
    end

    user = User.new

    form = UserForm.new(user)

    form.posts = [{ body: "TEXT" }]
    form.sync

    expect(user.posts[0].body).to eq("TEXT")
  end

  it "collection - pre-defined associations" do
    if Object.constants.include?(:User)
      Object.send(:remove_const, :User)
    end

    class User < ActiveRecord::Base
      has_many :posts
    end

    class UserForm < Biform::Form
      collection :posts do
        property :body
      end
    end

    user = User.new(name: "John")
    user.save

    post = Post.new(title: "Diary #1", user_id: user.id)
    post.save
    user.posts << post

    post = Post.new(title: "Diary #2", user_id: user.id)
    post.save
    user.posts << post

    form = UserForm.new(user)
    form.posts[0].body = "Memories #1"
    form.posts[1].body = "Memories #2"
    form.sync

    expect(user.posts[0].body).to eq("Memories #1")
    expect(user.posts[1].body).to eq("Memories #2")
  end

  it "collection - pre-defined and new associations" do
    if Object.constants.include?(:User)
      Object.send(:remove_const, :User)
    end

    class User < ActiveRecord::Base
      has_many :posts
    end

    class UserForm < Biform::Form
      collection :posts do
        property :body
      end
    end

    user = User.new(name: "John")
    user.save

    post1 = Post.new(title: "Diary #1", user_id: user.id)
    post1.save
    user.posts << post1

    post2 = Post.new(title: "Diary #2", user_id: user.id)
    post2.save
    user.posts << post2

    form = UserForm.new(user)
    form.posts = [
      { id: post1.id, body: "Memories #1" },
      { id: post2.id, body: "Memories #2" },
    ]
    form.sync

    expect(user.posts[0].body).to eq("Memories #1")
    expect(user.posts[1].body).to eq("Memories #2")

    form.posts = [
      { body: "Memories #3", title: "Diary #3" },
    ]
    form.sync

    expect(user.posts[0].body).to eq("Memories #1")
    expect(user.posts[1].body).to eq("Memories #2")
    expect(user.posts[2].body).to eq("Memories #3")
  end

  it "attribute - ignore virtual" do
    class UserForm < Biform::Form
      property :name
      property :lenght, virtual: true
    end

    user = User.new
    form = UserForm.new(user)

    form.name = "John"
    form.lenght = 4
    form.sync

    expect(user.name).to eq("John")
    expect(user).not_to respond_to(:length)
  end

  it "association - ignore virtual" do
    class UserForm < Biform::Form
      property :post do
        property :body
        property :lenght, virtual: true
      end
    end

    user = User.new
    form = UserForm.new(user)

    form.post.body = "TEXT"
    form.post.lenght = 4
    form.sync

    expect(user.post.body).to eq("TEXT")
    expect(user.post).not_to respond_to(:length)
  end

  it "association - ignore virtual" do
    if Object.constants.include?(:User)
      Object.send(:remove_const, :User)
    end

    class User < ActiveRecord::Base
      has_many :posts
    end

    class UserForm < Biform::Form
      collection :posts do
        property :body
        property :lenght, virtual: true
      end
    end

    user = User.new
    form = UserForm.new(user)

    form.posts = [{ body: "TEXT", length: 4 }]
    form.sync

    expect(user.posts[0].body).to eq("TEXT")
    expect(user.posts[0]).not_to respond_to(:length)
  end
end
