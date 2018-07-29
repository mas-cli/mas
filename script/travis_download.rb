#!/usr/bin/env ruby
#
# travis_download.rb
# mas
#
# Downloads build artifacts from Amazon S3 for use in the Deploy stage.
# This is necessary since each stage runs in a fresh VM, so files must be shared via a 3rd party.
#
# ** REQUIRED ENVIRONMENT VARIABLES **
#
# - AWS_REGION=us-west-2
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY
#

require 'aws-sdk-s3'

# S3_BUCKET variable
s3_bucket = ARGV[0]

# TRAVIS_BUILD_NUMBER variable
# https://docs.travis-ci.com/user/environment-variables/#default-environment-variables
travis_build_number = ARGV[1]

s3 = Aws::S3::Resource.new
s3.bucket(s3_bucket).objects(prefix: "#{travis_build_number}/").each { |o|
    puts "Downloading #{o} from S3 bucket #{s3_bucket}"
    # Strip off the numeric build dir, placing artifacts in the current directory.
    o.download_file(o.key.to_s.gsub(/^\d*\/(.*)/, '\1'))
}
