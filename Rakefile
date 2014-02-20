# Rake tasks for building a jekyll blog and deploying to S3.
#
# These tasks aren't intended to replace the `jekyll` executable,
# but provide convenient Rake-isms to generate the destination dir
# when necessary.
#
# To write to s3, it assumes there is a bucket field in the
# jekyll config:
#     aws:
#       bucket: 'my-s3-bucket'
#
# Make sure to have your AWS credentials in your ENV.
#
# The task `aws:write` will write the jekyll site to the bucket,
# spawning a thread for each object to be written.
require 'jekyll'

JEKYLL_CONFIGURATION = Jekyll.configuration({})
JEKYLL_DESTINATION = JEKYLL_CONFIGURATION["destination"]

task :default => JEKYLL_DESTINATION

desc 'Build jekyll'
task :build do |t|
  Jekyll::Commands::Build.process JEKYLL_CONFIGURATION
end

desc 'Cleanup jekyll build'
task :clean do |t|
  require 'fileutils'
  FileUtils.rm_r JEKYLL_DESTINATION if File.directory? JEKYLL_DESTINATION
end

file JEKYLL_DESTINATION => JEKYLL_CONFIGURATION["source"] do |t|
  Rake::Task[:build].invoke
end

namespace "aws" do
  require 'aws-sdk'

  desc 'write to the aws bucket'
  task :write => JEKYLL_DESTINATION do |t|
    require 'pathname'
    t.prerequisites.map do |destination|
      paths = Pathname.glob("#{destination}/**/*")
      threads = paths.select(&:file?).map do |path|
        Thread.new {
          relative_path = path.relative_path_from Pathname.new(destination)
          obj = bucket.objects[relative_path.to_path]
          puts %Q(Writing #{obj.key} to #{obj.bucket.name})
          obj.write path
          puts "- Object written: #{obj.public_url}"
        }
      end
      threads.each(&:join)
    end
  end

  def bucket
    bucket = JEKYLL_CONFIGURATION['aws']['bucket']
    AWS::S3.new.buckets[bucket]
  end
end

