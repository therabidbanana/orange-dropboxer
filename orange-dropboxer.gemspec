# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'orange_dropboxer/version'

Gem::Specification.new do |s|
  s.name         = "orange-dropboxer"
  s.version      = OrangeDropboxer::VERSION
  s.authors      = ["David Haslem"]
  s.email        = "therabidbanana@gmail.com"
  s.homepage     = "http://github.com/therabidbanana/orange-dropboxer"
  s.summary      = "Gives S3 dropboxes to Orange sites"
  s.description  = "Gives S3 dropboxes to Orange sites"

  s.files        = `git ls-files app lib`.split("\n")
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'
  s.required_rubygems_version = '>= 1.3.6'
end
