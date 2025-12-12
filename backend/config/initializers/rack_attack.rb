# frozen_string_literal: true

# Rack::Attack configuration for rate limiting and throttling
# Protect against brute force attacks and API abuse

class Rack::Attack
  # Throttle all requests by IP (100 requests per minute)
  throttle("req/ip", limit: 100, period: 1.minute) do |req|
    req.ip unless req.path.start_with?("/assets")
  end

  # Throttle login attempts by IP (5 attempts per 20 seconds)
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    if req.path == "/api/v1/auth/sign_in" && req.post?
      req.ip
    end
  end

  # Throttle login attempts by email (5 attempts per minute)
  throttle("logins/email", limit: 5, period: 1.minute) do |req|
    if req.path == "/api/v1/auth/sign_in" && req.post?
      # Extract email from request params
      req.params.dig("user", "email")&.downcase&.strip
    end
  end

  # Throttle password reset requests by IP (5 per hour)
  throttle("password_resets/ip", limit: 5, period: 1.hour) do |req|
    if req.path == "/api/v1/auth/password" && req.post?
      req.ip
    end
  end

  # Throttle sign ups by IP (10 per hour)
  throttle("signups/ip", limit: 10, period: 1.hour) do |req|
    if req.path == "/api/v1/auth/sign_up" && req.post?
      req.ip
    end
  end

  # Block suspicious requests
  blocklist("block/malicious") do |req|
    # Block requests with suspicious user agents
    Rack::Attack::Fail2Ban.filter("pentesters-#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 24.hours) do
      CGI.unescape(req.query_string) =~ /<script|%3Cscript/i ||
        req.path.include?("wp-admin") ||
        req.path.include?("phpmyadmin")
    end
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |_req|
    [
      429,
      { "Content-Type" => "application/json" },
      [{ error: "Rate limit exceeded. Try again later." }.to_json]
    ]
  end

  # Custom response for blocked requests
  self.blocklisted_responder = lambda do |_req|
    [
      403,
      { "Content-Type" => "application/json" },
      [{ error: "Forbidden" }.to_json]
    ]
  end
end

# Enable Rack::Attack
Rails.application.config.middleware.use Rack::Attack
