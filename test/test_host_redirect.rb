# encoding: UTF-8
require 'rubygems'
require 'minitest/autorun'
require "rack/test"
require 'rack-host-redirect'


INNER_APP = Proc.new { [200, {}, ['OK']] }


class TestHostRedirect < MiniTest::Test
  include Rack::Test::Methods

  def app
    Rack::HostRedirect.new(INNER_APP, {
      'www.FOO.com'               => 'www.bar.com',
      %w(one.foo.com two.foo.com) => 'three.foo.com',
      /bax.com$/                  => {host: 'www.bar.com'},
      'withopts.foo.com'          => {host: 'www.bar.com', path: '/', query: nil},
      'withexclude.foo.com'       => {host: 'www.bar.com', exclude: -> (request) {request.path.start_with?('/exclude/')}}
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

    get '/one', {'two' => 'three'}, 'HTTP_HOST' => 'one.foo.COM'
    assert_equal 301, last_response.status
    assert_equal 'http://three.foo.com/one?two=three', last_response['location']

    get '/one', {'two' => 'three'}, 'HTTP_HOST' => 'any.bax.com'
    assert_equal 301, last_response.status
    assert_equal 'http://www.bar.com/one?two=three', last_response['location']

    get '/one', {'two' => 'three'}, 'HTTP_HOST' => 'withopts.foo.com'
    assert_equal 301, last_response.status
    assert_equal 'http://www.bar.com/', last_response['location']

    get '/one', {'two' => 'three'}, 'HTTP_HOST' => 'withexclude.foo.com'
    assert_equal 301, last_response.status
    assert_equal 'http://www.bar.com/one?two=three', last_response['location']

    get '/exclude/one', {'two' => 'three'}, 'HTTP_HOST' => 'withexclude.foo.com'
    assert last_response.ok?
  end

  def test_includes_content_type_and_content_length_headers
    get '/one', {'two' => 'three'}, 'HTTP_HOST' => 'www.foo.COM'
    assert_equal 301, last_response.status
    assert_equal 'text/html', last_response['Content-Type']
    assert_equal '0', last_response['Content-Length']
  end

  def test_prefers_x_forwarded_host_when_available
    env = {'HTTP_HOST' => 'localhost', 'SERVER_NAME' => 'localhost', 'SERVER_PORT' => '3000'}
    get '/one', {'two' => 'three'}, env
    assert last_response.ok?
    get '/one', {'two' => 'three'}, env.merge('HTTP_X_FORWARDED_HOST' => 'www.foo.com')
    assert_equal 301, last_response.status
    assert_equal 'http://www.bar.com/one?two=three', last_response['location']
  end

  def test_config_circular_redirect_raises_argument_error
    assert_raises ArgumentError do
      Rack::HostRedirect.new(INNER_APP, {
        'LOOP.foo.com' => 'Loop.foo.com'
      })
    end
  end

  def test_config_without_host_value_raises_argument_error
    assert_raises ArgumentError do
      Rack::HostRedirect.new(INNER_APP, {
        'BADCONFIG' => {:path => '/'}
      })
    end
  end
end

