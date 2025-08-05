#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'time'
require 'uri'
require 'tempfile'
require 'fileutils'

class GitlabTokenRenever
  def initialize
    @api_url = ENV.fetch('GITLAB_API_URL', 'http://localhost')
    @token_file = '/var/opt/gitlab/.tokens/puppet_token'
    @expiry_threshold_days = 7
    @token = File.read(@token_file).strip
  end

  def write_token(token, target_path)
    f = Tempfile.create('.tkn', File.dirname(path))
    f.write(token)
    f.flush
    f.close
    File.rename(f, path)
  end

  def api_request(method, endpoint, body = nil)
    uri = URI("#{@api_url}/#{endpoint}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    request_class = case method.downcase
                    when :get    then Net::HTTP::Get
                    when :post   then Net::HTTP::Post
                    else raise "Unsupported HTTP method"
                    end

    request = request_class.new(uri)
    request['Authorization'] = "Bearer #{token}"
    request['Content-Type'] = 'application/json' if body
    request.body = body.to_json if body

    http.request(request)
  end

  # === Get current token info via /self ===
  def get_self_token_info
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

  # === Rotate the current token ===
  def rotate_self_token(new_expiry = nil)
    payload = {}
    payload[:expires_at] = new_expiry if new_expiry

    response = api_request(:post, 'personal_access_tokens/self/rotate', payload)

    case response
    when Net::HTTPSuccess
      JSON.parse(response.body)['token']
    when Net::HTTPUnauthorized
      abort "Token cannot be rotated (revoked, expired, or invalid)."
    when Net::HTTPForbidden
      abort "Token lacks permission to rotate (needs 'api' or 'self_rotate' scope)."
    else
      abort "Rotation failed: #{response.code} #{response.body}"
    end
  end

  # === Main logic ===
  def run
    info = get_self_token_info(old_token)
    expires_at_str = info['expires_at']

    if expires_at_str.nil?
      warn "Token has no expiration."
    else
      expires_at = Time.parse(expires_at_str).utc
      threshold = Time.now.utc + (@expiry_threshold_days * 86400)
      if expires_at > threshold
        puts "Token expires on #{expires_at}, still valid. No rotation needed."
        exit 0
      end
      puts "Token expires on #{expires_at}, rotating..."
    end

    new_expiry = (Time.now + 30 * 24 * 60 * 60).strftime('%Y-%m-%d')
    new_token = rotate_self_token(old_token, new_expiry)
    puts "Token rotated in GitLab."

    write_token(new_token, TOKEN_FILE)
    puts "New token written to #{TOKEN_FILE}."

    puts "Rotation complete."
  end
end

if __FILE__ == $0
  GitlabTokenRenever.new.run
end
