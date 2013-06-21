require 'rack'
require 'uri'

class Rack::HostRedirect

  def initialize(app, host_mapping = nil, &block)
    @app = app
    @host_mapping = downcase_keys(host_mapping) if host_mapping
    @block = block
  end

  def call(env)
    request = Rack::Request.new(env)
    host = request.host.downcase # downcase for case-insensitive matching

    updated_host = (@host_mapping && @host_mapping[host]) || (@block && @block.call(host, env))

    if updated_host && updated_host.downcase != host
      location = replace_host(request.url, updated_host)
      [301, {'Location' => location}, []]
    else
      @app.call(env)
    end
  end

  private

    def downcase_keys hsh
      hsh.inject({}) {|out, (k, v)| out[k.downcase] = v; out }
    end

    def replace_host url, host
      url = URI.parse(url)
      url.host = host
      url.to_s
    end
end
