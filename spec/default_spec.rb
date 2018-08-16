require "spec_helper"

RSpec.describe "Default" do
  before do
    class User < ActiveRecord::Base; end

    if Object.constants.include?(:UserForm)
      Object.send(:remove_const, :UserForm)
    end
  end

  it "string" do
    class UserForm < Biform::Form
      property :name, default: "Demetrio"
    end

    form = UserForm.new(User.new)

    expect(form.name).to eq("Demetrio")
  end

  it "integer" do
    class UserForm < Biform::Form
      property :id, default: 0
    end

    form = UserForm.new(User.new)

    expect(form.id).to eq(0)
  end

  it "proc" do
    class UserForm < Biform::Form
      @@timestamp = Time.now.iso8601

      def self.timestamp
        @@timestamp
      end

      property :datetime, virtual: true, type: Types::Strict::String, default: proc { UserForm.timestamp }
    end

    form = UserForm.new(User.new)

    expect(form.datetime).to eq(UserForm.timestamp)
  end
end
