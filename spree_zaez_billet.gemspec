# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_zaez_billet'
  s.version     = '3.0.4.1'
  s.summary     = 'Adds Billet as a Payment Method to Spree Commerce'
  s.description = s.summary

  begin
    require 'ruby_dep/travis'
    s.required_ruby_version = RubyDep::Travis.new.version_constraint
  rescue LoadError
    abort "Install 'ruby_dep' gem before building this gem"
  end

  s.author    = 'Zaez Team'
  s.email     = 'contato@zaez.net'
  s.homepage  = 'https://github.com/zaeznet/spree_zaez_billet'

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 3.0.0'
  s.add_dependency 'brcobranca', '~> 6.4.0'

  s.add_development_dependency 'poltergeist', '~> 1.5.0'
  s.add_development_dependency 'capybara', '~> 2.4'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.5'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails', '~> 3.1'
  s.add_development_dependency 'sass-rails', '~> 5.0.0.beta1'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-bundler'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'guard-shell'
  s.add_development_dependency 'ruby_dep', '~> 1.2'
end
