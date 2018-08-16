module DatabaseHelper
  require "active_record"
  require "sqlite3"

  def self.connect
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
  end

  # rubocop:disable Metrics/LineLength
  def self.migrate
    ActiveRecord::Base.connection.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name VARCHAR);")
    ActiveRecord::Base.connection.execute("CREATE TABLE posts (id INTEGER PRIMARY KEY, user_id INTEGER, title VARCHAR, body VARCHAR);")
  end
  # rubocop:enable Metrics/LineLength
end
