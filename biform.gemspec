Gem::Specification.new do |s|
  s.name        = 'biform'
  s.version     = '0.1'
  s.date        = '2018-08-10'
  s.summary     = "Reform replacement"
  s.description = "Reform replacement"
  s.authors     = ["Dmitriy Komarickiy"]
  s.email       = 'lochnessathome@gmail.com'
  s.files       = ["lib/biform.rb"]

  s.add_dependency "dry-types", "~> 0.12.2"

  s.add_development_dependency "bundler", "~> 1.16.1"
  s.add_development_dependency "pry", "~> 0.11.0"
  s.add_development_dependency "rspec-core", "~> 3.7.0"
  s.add_development_dependency "rspec-expectations", "~> 3.7.0"

  s.add_development_dependency "activerecord", "~> 5.1"
  s.add_development_dependency "sqlite3", "~> 1.3"
end
