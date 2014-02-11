require 'rack/request'

class Rack::HostRedirect

  def initialize(app, host_mapping)
    @app = app
    @host_mapping = downcase_keys(host_mapping)
  end

  def call(env)
    request = Rack::Request.new(env)
    host = request.host.downcase # downcase for case-insensitive matching

    updated_host = @host_mapping[host]

    if updated_host && updated_host != host
      location = replace_host(request.url, updated_host)
      [301, {'Location' => location}, []]
    else
      @app.call(env)
    end
  end

  private

    def downcase_keys hsh
      hsh.inject({}) {|out, (k, v)| out[k.downcase] = v.downcase; out }
    end

    # Captures everything in url except the host:
    #
    #     REPLACE_HOST_REGEX =~ 'https://foo.com/bar?baz=qux'
    #
    #     $1 == 'https://'
    #     $2 == '/bar?baz=qux'
    REPLACE_HOST_REGEX = /(https?:\/\/)[^\/\?:]+(.*)/

    def replace_host url, host
      REPLACE_HOST_REGEX =~ url
      "#{$1}#{host}#{$2}"
    end
end
