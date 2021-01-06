$:.push File.expand_path('lib', __dir__)

Gem::Specification.new do |s|
  s.name        = 'breathing'
  s.version     = '0.0.10'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Akira Kusumoto']
  s.email       = ['akirakusumo10@gmail.com']
  s.homepage    = 'https://github.com/bluerabbit/breathing'
  s.summary     = 'Audit logging for database'
  s.description = 'Audit logging for database'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
  s.licenses      = ['MIT']

  s.bindir      = 'exe'
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.add_runtime_dependency 'thor'

  s.add_dependency 'activerecord', ['>= 6.0.0']
  s.add_dependency 'hairtrigger'
  s.add_dependency 'mysql2'
  s.add_dependency 'pg'
  s.add_dependency 'terminal-table'
  s.add_dependency 'rubyXL', ['>= 3.4.0']
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'rspec', '~> 3.9'
end
