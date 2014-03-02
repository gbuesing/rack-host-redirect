Rack::HostRedirect
==================

A lean and simple Rack middleware that 301 redirects requests from one host to another.

This is useful for environments where it's difficult or impossible to implement this via Nginx/Apache configuration (e.g. Heroku.)

I'm using this to redirect traffic from a *.herokuapp.com subdomain to a custom domain, and to redirect the www subdomain to the bare domain.

Configuration below is for Rails, but this middleware should also work just fine with Sinatra and bare Rack apps.


Rails configuration
-------------------

in Gemfile:

```ruby
gem 'rack-host-redirect'
```

in config/application.rb:

```ruby
config.middleware.use Rack::HostRedirect, 'myapp.herokuapp.com' => 'www.myapp.com'
```

With this configuration, all requests to ```myapp.herokuapp.com``` will be 301 redirected to ```www.myapp.com```.

Path, querystring and protocol are preserved, so a request to:

    https://myapp.herokuapp.com/foo?bar=baz

will be 301 redirected to:

    https://www.myapp.com/foo?bar=baz

Addtional host redirections can be specified as key-value pairs in the host mapping hash:

```ruby
config.middleware.use Rack::HostRedirect, {
  'myapp.herokuapp.com' => 'www.myapp.com',
  'old.myapp.com'       => 'new.myapp.com'
}
```

Multiple hosts that map to the same redirect destination host can be specified by an Array key:

```ruby
config.middleware.use Rack::HostRedirect, {
  %w(myapp.herokuapp.com foo.myapp.com) => 'www.myapp.com'
}
```

URI methods to set for redirect location can be specified as a hash value:

```ruby
# Don't preserve path or query on redirect:
config.middleware.use Rack::HostRedirect, {
  'bar.myapp.com' => {host: 'www.myapp.com', path: '/', query: nil}
}
```

When specifying a URI methods hash, the ```:host``` key is required; all other URI keys are optional.


Testing with Rails Integration Test
-----------------------------------

```ruby
require 'test_helper'

class HostTest < ActionDispatch::IntegrationTest
  test "myapp.herokuapp.com is redirected to www.myapp.com" do
    get 'https://myapp.herokuapp.com/'
    assert_redirected_to 'https://www.myapp.com/'
    follow_redirect!
    assert_response :success
  end
end
```
