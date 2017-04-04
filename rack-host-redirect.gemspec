Gem::Specification.new do |s|
  s.name    = 'rack-host-redirect'
  s.version = '1.3.0'
  s.date    = '2017-04-04'
  s.author  = 'Geoff Buesing'
  s.email   = 'gbuesing@gmail.com'
  s.summary = 'Lean and simple host redirection via Rack middleware'
  s.license = 'MIT'
  s.homepage = 'https://github.com/gbuesing/rack-host-redirect'

  s.add_dependency 'rack'
  s.add_development_dependency 'rack-test'

  s.files = ['lib/rack-host-redirect.rb', 'lib/rack/host_redirect.rb']
end