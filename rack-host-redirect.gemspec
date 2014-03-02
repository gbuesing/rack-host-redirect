Gem::Specification.new do |s|
  s.name    = 'rack-host-redirect'
  s.version = '1.2.1'
  s.date    = '2014-02-11'
  s.author  = 'Geoff Buesing'
  s.email   = 'gbuesing@gmail.com'
  s.summary = 'Lean and simple host redirection via Rack middleware'
  s.license = 'MIT'
  s.homepage = 'https://github.com/gbuesing/rack-host-redirect'

  s.add_dependency 'rack'
  s.add_development_dependency 'rack-test'

  s.files = ['lib/rack-host-redirect.rb', 'lib/rack/host_redirect.rb']
end