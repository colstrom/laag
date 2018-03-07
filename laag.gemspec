
# -*- ruby -*-

Gem::Specification.new do |gem|
  gem.name        = 'laag'
  gem.version     = `git describe --tags --abbrev=0`.chomp
  gem.licenses    = 'MIT'
  gem.authors     = ['Chris Olstrom']
  gem.email       = 'chris@olstrom.com'
  gem.homepage    = 'http://colstrom.github.io/laag/'
  gem.summary     = 'Library as a Gem'
  gem.description = 'Simplifies platform-native dependency management'

  gem.files         = `git ls-files -z`.split("\x0")
  gem.executables   = `git ls-files -z -- bin/*`.split("\x0").map { |f| File.basename(f) }
end
