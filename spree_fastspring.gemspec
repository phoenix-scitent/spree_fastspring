# -*- encoding: utf-8 -*-
require File.expand_path('../lib/spree_fastspring/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Kevin Hopkins"]
  gem.email         = ["khopkins218@gmail.com"]
  gem.description   = %q{Fastspring integration for Spree}
  gem.summary       = %q{Allows for fastspring integration into Spree for international purchases}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "spree_fastspring"
  gem.require_paths = ["lib"]
  gem.version       = SpreeFastspring::VERSION
  
  if File.exists?('INSTALL')
    gem.post_install_message = File.read("INSTALL")
  end
end
