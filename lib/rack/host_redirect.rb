require 'rack'
require 'uri'

class Rack::HostRedirect

  def initialize(app, host_mapping = nil, &block)
    @app = app
    @host_mapping = downcase_keys(host_mapping) if host_mapping
    @block = block
  end

  def call(env)
    host = (env['HTTP_HOST'] || env['SERVER_NAME']).downcase
    updated_host = (@host_mapping && @host_mapping[host]) || (@block && @block.call(host, env))

    if updated_host
      redirect_to(updated_host, env)
    else
      @app.call(env)
    end
  end

  private

    def downcase_keys hsh
      hsh.inject({}) {|out, (k, v)| out[k.downcase] = v; out }
    end

    def redirect_to updated_host, env
      request = Rack::Request.new(env)
      location = URI.parse(request.url)
      location.host = updated_host
      [301, {'Location' => location.to_s}, []]
    end
end
