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

    if updated_uri_opts = @host_mapping[host]
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
          oldhost = oldhost.downcase

          if oldhost == opts[:host]
            raise ArgumentError, "Circular redirect to #{oldhost}"
          else
            out[oldhost] = opts
          end
        end

        out
      end
    end

    def update_url url, opts
      uri = URI(url)

      opts.each do |k, v| 
        uri.send(:"#{k}=", v)
      end

      uri.to_s
    end
end
