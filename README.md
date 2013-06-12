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
# Insert Rack::HostRedirect before middleware that serves static assets,
# so that static assets in /public (e.g. robots.txt) won't be served under an obsolete host.
# config.serve_static_assets must be set to true for ActionDispatch::Static to be present
# (Heroku Cedar will force config.serve_static_assets to true.)
config.middleware.insert_before ActionDispatch::Static, Rack::HostRedirect, {
  'myapp.herokuapp.com' => 'www.myapp.com',
  'old.myapp.com'       => 'new.myapp.com'
}
```

With this configuration, all requests to ```myapp.herokuapp.com``` will be 301 redirected to ```www.myapp.com```, and all requests to ```old.myapp.com``` will be 301 redirected to ```new.myapp.com```.

Path and querystring are preserved, so a request to:

    https://myapp.herokuapp.com/foo?bar=bar

will be 301 redirected to:

    https://www.myapp.com/foo?bar=baz


Rack configuration
------------------

Example config.ru:

```ruby
require 'rubygems'
require 'rack-host-redirect'
require 'myapp'

# Be sure to insert this before any middleware that serves static assets
use Rack::HostRedirect, {
  'myapp.herokuapp.com' => 'www.myapp.com',
  'old.myapp.com'       => 'new.myapp.com'
}

run MyApp
```


Matching via block
------------------

You can optionally specify a block, if you have matching criteria not satisfied by a simple hash lookup:

```ruby
use Rack::MobileDetect

# Redirects to mobile subdomain when a mobile device is detected
use Rack::HostRedirect do |host, env|
  'm.myapp.com' if env['X_MOBILE_DEVICE']
end
```

The request host and Rack env will be yielded to the block. The block must return the host to redirect to, or nil if no redirect is desired.
