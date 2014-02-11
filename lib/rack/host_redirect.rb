require 'rack/request'
require 'uri'

class Rack::HostRedirect

  def initialize(app, host_mapping)
    @app = app
    @host_mapping = preprocess_mapping(host_mapping)
  end

  def call(env)
    request = Rack::Request.new(env)
    host = request.host.downcase # downcase for case-insensitive matching

    updated_uri_opts = @host_mapping[host]

    if updated_uri_opts && updated_uri_opts[:host] != host
      location = update_url(request.url, updated_uri_opts)
      [301, {'Location' => location}, []]
    else
      @app.call(env)
    end
  end

  private

    def preprocess_mapping hsh
      hsh.inject({}) do |out, (k, opts)| 
        opts = {:host => opts} if opts.is_a?(String)
        
        if newhost = opts[:host]
          opts[:host] = newhost.downcase
        else
          raise ArgumentError, ":host key must be specified in #{opts.inspect}"
        end

        [k].flatten.each do |oldhost|
          out[oldhost.downcase] = opts
        end

        out
      end
    end

    def update_url url, opts
      uri = URI(url)

      opts.each do |k, v| 
        setter = :"#{k}="
        uri.send(setter, v) if uri.respond_to?(setter)
      end

      uri.to_s
    end
end
