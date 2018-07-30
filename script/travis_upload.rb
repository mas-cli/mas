#!/usr/bin/env ruby
#
# travis_upload.rb
# mas
#
# Uploads build artifacts to Amazon S3 so that they can be used in the Deploy stage.
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
if s3_bucket.nil? || s3_bucket.empty?
    puts "s3_bucket is required"
    exit 1
end

# TRAVIS_BUILD_NUMBER variable
# https://docs.travis-ci.com/user/environment-variables/#default-environment-variables
travis_build_number = ARGV[1]
if travis_build_number.nil? || travis_build_number.empty?
    puts "travis_build_number is required"
    exit 2
end

s3 = Aws::S3::Resource.new

# Upload all .zip and .tar.gz files
Dir["*.{zip,tar.gz}"].each { |f|
    puts "Uploading #{f} to S3 bucket #{s3_bucket}"
    # Place files into numbered build dir
    s3.bucket(s3_bucket)
        .put_object(key: "#{travis_build_number}/#{f}")
        .upload_file(f)
}
