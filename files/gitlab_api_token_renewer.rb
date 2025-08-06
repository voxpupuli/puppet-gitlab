#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'time'
require 'uri'
require 'tempfile'

class GitlabApiTokenRenewer
  def initialize
    @api_url = ENV.fetch('GITLAB_API_URL', 'http://localhost')
    @token_file = ENV.fetch('GITLAB_API_TOKEN_FILE', '/var/opt/gitlab/.tokens/puppet_token')
    @token_renew_days = ENV.fetch('GITLAB_API_TOKEN_RENEW_DAYS', '7').to_i
    @new_token_ttl_days = ENV.fetch('GITLAB_API_NEW_TOKEN_TTL_DAYS', '30').to_i
    @token = File.read(@token_file).strip

    uri = URI(@api_url)
    @http = Net::HTTP.new(uri.host, uri.port)
    @http.use_ssl = uri.scheme == 'https'
  end

  def write_token
    f = Tempfile.create('.tkn', File.dirname(@token_file))
    f.write(token)
    f.flush
    f.close
    File.rename(f, @token_file)
  end

  def api_request(method, endpoint, body = nil)
    request_class = case method.downcase
                    when :get    then Net::HTTP::Get
                    when :post   then Net::HTTP::Post
                    else raise "Unsupported HTTP method"
                    end

    request = request_class.new(uri)
    request['Authorization'] = "Bearer #{token}"
    request['Content-Type'] = 'application/json' if body
    request.body = body.to_json if body

    @http.request(request)
  end

  def get_current_token_info
    response = api_request(:get, 'personal_access_tokens/self')

    case response
    when Net::HTTPSuccess
      JSON.parse(response.body)
    when Net::HTTPUnauthorized
      abort "Token is invalid, revoked, or expired."
    else
      abort "Failed to get token info: #{response.code} #{response.body}"
    end
  end

  def rotate_current_token(new_expiry = nil)
    payload = {}
    payload[:expires_at] = new_expiry if new_expiry

    response = api_request(:post, 'personal_access_tokens/self/rotate', payload)

    case response
    when Net::HTTPSuccess
      @token = JSON.parse(response.body)['token']
    when Net::HTTPUnauthorized
      abort "Token cannot be rotated (revoked, expired, or invalid)."
    when Net::HTTPForbidden
      abort "Token lacks permission to rotate (needs 'api' or 'self_rotate' scope)."
    else
      abort "Rotation failed: #{response.code} #{response.body}"
    end
  end

  def run
    info = get_current_token_info
    expires_at_str = info['expires_at']

    if expires_at_str.nil?
      warn "Token has no expiration."
    else
      expires_at = Time.parse(expires_at_str).utc
      threshold = Time.now.utc + (@token_renew_days * 86400)
      if expires_at > threshold
        puts "Token expires on #{expires_at}, still valid. No rotation needed."
        exit 0
      end
      puts "Token expires on #{expires_at}, rotating..."
    end

    new_expiry = (Time.now + 30 * 24 * 60 * 60).strftime('%Y-%m-%d')
    rotate_current_token(new_expiry)
    puts "Token rotated in GitLab."

    write_token
    puts "New token written to #{@token_file}."

    puts "Rotation complete."
  end
end

if __FILE__ == $0
  GitlabApiTokenRenewer.new.run
end
