#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

# Fetches still images ("snapshots") from a Reolink camera over its local
# HTTP API. Talking to the camera is a two-step dance: log in to obtain a
# session token, then request a snapshot with that token.
class ReolinkCamera
  # Reolink expects a "random string" (rs) on every request to defeat caching.
  # The value is arbitrary; only its presence matters.
  RS = 'spienzler'

  # Login and snapshot live under different paths, as in the original script.
  LOGIN_PATH = '/api.cgi'
  SNAP_PATH = '/cgi-bin/api.cgi'

  LoginError = Class.new(StandardError)

  attr_reader :host, :user, :password

  # Builds a camera from a `KEY=VALUE` env file (see bin/rl.env.example).
  # Blank lines and `#` comments (including the `#!/bin/bash` shebang) are
  # ignored, so the file stays compatible with the previous shell script.
  def self.from_env_file(path)
    settings = {}
    File.foreach(path) do |line|
      line = line.strip
      next if line.empty? || line.start_with?('#')

      key, value = line.split('=', 2)
      settings[key] = value
    end

    new(host: settings.fetch('HOST'),
        user: settings.fetch('USER'),
        password: settings.fetch('PW'))
  end

  def initialize(host:, user:, password:, http: HttpClient.new)
    @host = host
    @user = user
    @password = password
    @http = http
  end

  # Authenticates and returns the session token.
  def login
    response = JSON.parse(@http.post_json(login_url, login_payload))
    token = response.dig(0, 'value', 'Token', 'name')
    raise LoginError, 'login failed: no token returned' if token.to_s.empty?

    token
  end

  # Downloads a snapshot and writes the JPEG to `output_path`.
  # Returns the path so callers can chain on it.
  def snapshot(output_path)
    File.binwrite(output_path, @http.get(snapshot_url(login)))
    output_path
  end

  private

  def login_url
    build_url(LOGIN_PATH, cmd: 'Login')
  end

  def snapshot_url(token)
    build_url(SNAP_PATH, cmd: 'Snap', channel: 0, rs: RS, token: token)
  end

  def build_url(path, params)
    url = URI("http://#{host}#{path}")
    url.query = URI.encode_www_form(params)
    url.to_s
  end

  def login_payload
    [{
      cmd: 'Login',
      action: 0,
      param: { rs: RS, User: { userName: user, password: password } }
    }]
  end

  # Minimal Net::HTTP wrapper, kept separate so the camera logic can be
  # tested with a stubbed transport instead of real network calls.
  class HttpClient
    def post_json(url, body)
      uri = URI(url)
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request.body = body.to_json
      perform(uri, request)
    end

    def get(url)
      uri = URI(url)
      perform(uri, Net::HTTP::Get.new(uri))
    end

    private

    def perform(uri, request)
      Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(request) }.body
    end
  end
end

# CLI entry point: rl-snap.rb <output-file>
if __FILE__ == $PROGRAM_NAME
  output_path = ARGV[0] || abort("usage: #{File.basename($PROGRAM_NAME)} <output-file>")
  camera = ReolinkCamera.from_env_file(File.join(__dir__, 'rl.env'))
  camera.snapshot(output_path)
end
