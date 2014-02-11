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

    updated_host = @host_mapping[host]

    if updated_host && updated_host != host
      location = replace_host(request.url, updated_host)
      [301, {'Location' => location}, []]
    else
      @app.call(env)
    end
  end

  private

    def preprocess_mapping hsh
      hsh.inject({}) do |out, (k, v)| 
        [k].flatten.each do |host|
          out[host.downcase] = v.downcase
        end
        out
      end
    end

    def replace_host url, host
      uri = URI(url)
      uri.host = host
      uri.to_s
    end
end
