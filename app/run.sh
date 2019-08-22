#!/usr/bin/env ruby

require 'date'

BASE_DIR='/srv/www/cam/0'

today = Date.today.to_s
now = Time.now.strftime('%H-%M')
img_file_name = "#{BASE_DIR}/#{today}-#{now}.jpg"
system("raspistill -rot 180 -o #{img_file_name}")
