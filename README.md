Rack::HostRedirect
==================

A lean and simple Rack middleware that 301 redirects requests from one host to another.

This is useful for environments where it's difficult or impossible to implement this via Nginx/Apache configuration (e.g. Heroku.)

I'm using this to redirect traffic from a *.herokuapp.com subdomain to a custom domain.


Rails configuration
-------------------

in Gemfile:

```ruby
gem 'rack-host-redirect'
```

in config/application.rb:

```ruby
config.middleware.use Rack::HostRedirect, {
  'myapp.herokuapp.com' => 'www.myapp.com',
  'old.myapp.com'       => 'new.myapp.com'
}
```

With this configuration, all requests to ```myapp.herokuapp.com``` will be 301 redirected to ```www.myapp.com```, and all requests to ```old.myapp.com``` will be 301 redirected to ```new.myapp.com```.

Path and querystring are preserved, so a request to:

    https://myapp.herokuapp.com/foo?bar=baz

will be 301 redirected to:

    https://www.myapp.com/foo?bar=baz

Multiple legacy hosts that redirect to the same new host can be specified as an array:

```ruby
config.middleware.use Rack::HostRedirect, {
  %w(myapp.herokuapp.com foo.myapp.com) => 'www.myapp.com'
}
```

URI methods to set for redirect location can be specified as a hash:

```ruby
# Don't preserve path or query on redirect:
config.middleware.use Rack::HostRedirect, {
  'bar.myapp.com' => {host: 'www.myapp.com', path: '/', query: nil}
}
```

When specifying a URI methods hash, the ```:host``` key is required; all other URI keys are optional.


Rack configuration
-------------------

```ruby
# config.ru
require 'rubygems'
require 'rack-host-redirect'

use Rack::HostRedirect, {
  'legacy.myapp.com' => 'www.myapp.com'
}

run MyApp
```
