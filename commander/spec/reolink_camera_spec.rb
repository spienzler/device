# frozen_string_literal: true

require 'tmpdir'
require 'tempfile'
require_relative '../../bin/rl-snap'

RSpec.describe ReolinkCamera do
  let(:http) { instance_double(ReolinkCamera::HttpClient) }
  let(:camera) do
    described_class.new(host: 'cam.local:8081', user: 'admin', password: 's3cret', http: http)
  end

  def login_response(token: 'TOKEN123')
    [{ 'value' => { 'Token' => { 'name' => token } } }].to_json
  end

  describe '#login' do
    it 'returns the token from the API response' do
      allow(http).to receive(:post_json).and_return(login_response)

      expect(camera.login).to eq('TOKEN123')
    end

    it 'posts the Login command and credentials to the login endpoint' do
      expect(http).to receive(:post_json) do |url, payload|
        expect(url).to eq('http://cam.local:8081/api.cgi?cmd=Login')
        expect(payload).to eq(
          [{ cmd: 'Login', action: 0,
             param: { rs: 'spienzler', User: { userName: 'admin', password: 's3cret' } } }]
        )
        login_response
      end

      camera.login
    end

    it 'raises a LoginError when the response carries no token' do
      allow(http).to receive(:post_json).and_return([{ 'value' => {} }].to_json)

      expect { camera.login }.to raise_error(ReolinkCamera::LoginError)
    end
  end

  describe '#snapshot' do
    before { allow(http).to receive(:post_json).and_return(login_response) }

    it 'requests the snapshot with the session token and writes it to disk' do
      expect(http).to receive(:get)
        .with('http://cam.local:8081/cgi-bin/api.cgi?cmd=Snap&channel=0&rs=spienzler&token=TOKEN123')
        .and_return('JPEG-BYTES')

      Dir.mktmpdir do |dir|
        path = File.join(dir, 'snap.jpg')

        expect(camera.snapshot(path)).to eq(path)
        expect(File.binread(path)).to eq('JPEG-BYTES')
      end
    end
  end

  describe '.from_env_file' do
    it 'parses HOST/USER/PW and ignores the shebang, comments and blank lines' do
      Tempfile.create('rl.env') do |file|
        file.write(<<~ENV)
          #!/bin/bash

          # camera connection
          HOST=cam.local:8081
          USER=admin
          PW=s3cret
        ENV
        file.flush

        camera = described_class.from_env_file(file.path)

        expect(camera.host).to eq('cam.local:8081')
        expect(camera.user).to eq('admin')
        expect(camera.password).to eq('s3cret')
      end
    end

    it 'raises when a required key is missing' do
      Tempfile.create('rl.env') do |file|
        file.write("HOST=cam.local:8081\n")
        file.flush

        expect { described_class.from_env_file(file.path) }.to raise_error(KeyError)
      end
    end
  end
end
