Gem::Specification.new do |s|
  s.name              = 'soak'
  s.version           = '0.0.2'
  s.platform          = Gem::Platform::RUBY
  s.authors           = [ 'Samer Abdel-Hafez' ]
  s.email             = %w( sam@arahant.net )
  s.homepage          = 'http://github.com/nopedial/soak'
  s.summary           = 'soak'
  s.description       = 'just an arp sponge'
  s.rubyforge_project = s.name
  s.files             = `git ls-files`.split("\n")
  s.executables       = %w( soakd )
  s.require_path      = 'lib'

  s.required_ruby_version = '>= 1.9.3'
  s.add_dependency 'asetus', '>= 0.0.7'
  s.add_dependency 'logger', '>= 1.2.8'
end
