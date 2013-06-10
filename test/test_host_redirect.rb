require 'rubygems'
require 'test/unit'
require "rack/test"
require 'rack-host-redirect'


INNER_APP = Proc.new { [200, {}, ['OK']] }


class TestHostRedirect < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Rack::HostRedirect.new(INNER_APP, {
      'www.FOO.com' => 'www.bar.com'
    })
  end

  def test_host_redirect
    get '/one', {'two' => 'three'}, 'HTTP_HOST' => 'www.foo.COM'
    assert_equal 301, last_response.status
    assert_equal 'http://www.bar.com/one?two=three', last_response['location']
    follow_redirect!
    assert last_response.ok?
    get '/one', {'two' => 'three'}, 'HTTP_HOST' => 'www.baz.com'
    assert last_response.ok?
  end
end


class TestHostRedirectWithBlock < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Rack::HostRedirect.new(INNER_APP, 'www.foo.com' => 'www.bar.com') do |host, env|
      'beatles.bar.com' if host =~ /^(john|paul|george|ringo)\.bar\.com/
    end
  end

  def test_host_redirect
    get '/one', {'two' => 'three'}, 'HTTP_HOST' => 'www.foo.COM'
    assert_equal 301, last_response.status
    assert_equal 'http://www.bar.com/one?two=three', last_response['location']
    follow_redirect!
    assert last_response.ok?
    get '/one', {'two' => 'three'}, 'HTTP_HOST' => 'george.bar.com'
    assert_equal 301, last_response.status
    assert_equal 'http://beatles.bar.com/one?two=three', last_response['location']
  end
end
