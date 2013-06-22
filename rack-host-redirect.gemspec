Gem::Specification.new do |s|
  s.name    = 'rack-host-redirect'
  s.version = '1.1.2'
  s.date    = '2013-06-22'
  s.author  = 'Geoff Buesing'
  s.email   = 'gbuesing@gmail.com'
  s.summary = 'Lean and simple host redirection via Rack middleware'
  s.license = 'MIT'
  s.homepage = 'https://github.com/gbuesing/rack-host-redirect'

  s.add_dependency 'rack'
  s.add_development_dependency 'rack-test'

  s.files = ['lib/rack-host-redirect.rb', 'lib/rack/host_redirect.rb']
end