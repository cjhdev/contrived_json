require File.expand_path("../lib/contrived_json/version", __FILE__)

Gem::Specification.new do |s|
    s.name    = "contrived_json"
    s.version = ContrivedJSON::VERSION
    s.date = Date.today.to_s
    s.summary = "A Flex/Bison based JSON parser"
    s.author  = "Cameron Harper"
    s.email = "contact@cjh.id.au"
    s.homepage = "https://github.com/cjhdev/contrived_json"
    s.files = Dir.glob("ext/**/*.{c,h,rb}") + Dir.glob("lib/**/*.rb") + Dir.glob("test/**/*.rb") + ["rakefile"]
    s.extensions = ["ext/contrived_json/ext_parser/extconf.rb"]
    s.license = 'MIT'
    s.test_files = Dir.glob("test/**/*.rb")
    s.add_development_dependency 'rake-compiler'
    s.add_development_dependency 'rake'
    s.add_development_dependency 'test-unit'
    s.required_ruby_version = '>= 1.9.3'
end
