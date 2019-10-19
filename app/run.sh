#!/usr/bin/env ruby

require 'date'
require 'yaml'

BASE_DIR='/srv/www/cam/0'

settings = YAML.load(File.read(File.dirname($0) + '/spienzler.yaml'))

today = Date.today.to_s
now = Time.now.strftime('%H-%M')
img_file_name = "#{today}-#{now}.jpg"
img_file_path = "#{BASE_DIR}/#{img_file_name}"
system("raspistill -rot 180 -o #{img_file_path}")
#system("touch #{img_file_path}")

# webdav upload
wd_config = settings['upload']['webdav']
wd_cmd = "curl --user #{wd_config['user']}:#{wd_config['password']} -T #{img_file_path} #{wd_config['url']}/#{img_file_name}"
%x[#{wd_cmd}]

# scp upload
#system("scp -P 23555 #{img_file_name} rpcw-bsk@jump.s-it.ch:/var/www/html/bsk/0")
