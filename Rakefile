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
require 'pathname'
require 'fileutils'
require 'digest'
require 'jekyll'
require 'rack/mime'

JEKYLL_CONFIGURATION = Jekyll.configuration({})
JEKYLL_DESTINATION = JEKYLL_CONFIGURATION["destination"]
DRAFT_EPISODES = FileList["episodes/_drafts/*.md"]
PUBLISHED_EPISODES = FileList["episodes/_posts/*.md"]


task :default => JEKYLL_DESTINATION

desc 'Build jekyll'
task :build do |t|
  Jekyll::Commands::Build.process JEKYLL_CONFIGURATION
end

task :build_drafts do |t|
  Jekyll::Commands::Build.process JEKYLL_CONFIGURATION.merge("show_drafts" => true)
end

desc 'Cleanup jekyll build'
task :clean do |t|
  FileUtils::Verbose.rm_r JEKYLL_DESTINATION if File.directory? JEKYLL_DESTINATION
end

file JEKYLL_DESTINATION => JEKYLL_CONFIGURATION["source"] do |t|
  Rake::Task[:build].invoke
end

directory "episodes/_posts"
directory "episodes/_drafts"

desc "Publish a draft (optionally specifying which one)"
task :publish, [:post] => "episodes/_posts" do |t, args|
  drafts = DRAFT_EPISODES.map {|p| Pathname.new(p) }
  drafts.keep_if {|d| d.basename(d.extname) == args.post } unless args.post.nil?

  drafts.each do |draft|
    FileUtils::Verbose.mv draft.to_path, "episodes/_posts/#{Date.today.iso8601}-#{draft.basename}"
  end
end

desc "Create a new draft (autoincrements episode number)"
task :draft => "episodes/_drafts" do |t|
  episode_numbers = (DRAFT_EPISODES | PUBLISHED_EPISODES).map do |f|
    Pathname.new(f).basename.to_s[/-?(\d+)\.\w+$/, 1]
  end.compact.uniq.map(&:to_i)

  newest_episode = (episode_numbers.max or 0) + 1
  filename = sprintf("%03d", newest_episode)
  FileUtils::Verbose.touch "episodes/_drafts/#{filename}.md"
end

namespace "aws" do
  require 'aws-sdk'

  desc 'Write to the aws bucket'
  task :write => JEKYLL_DESTINATION do |t|
    t.prerequisites.map do |destination|
      paths = Pathname.glob("#{destination}/**/*")
      threads = paths.select(&:file?).map do |path|
        Thread.new {
          relative_path = path.relative_path_from Pathname.new(destination)
          obj = bucket.objects[relative_path.to_path]
          if obj.exists?
            digest = Digest::MD5.file(path).hexdigest
            if obj.etag != %Q("#{digest}")
              puts %Q(Writing changed object: #{obj.key} (#{obj.etag}|#{digest}))
              write_object(obj, path)
            end
          else
            puts %Q(Writing new object: #{obj.key})
            write_object(obj, path)
          end
        }
      end
      threads.each(&:join)
    end
  end

  desc 'Print all the S3 server logs to STDOUT'
  task :log, [:limit] do |t, args|
    logs.each(limit: args.limit) do |obj|
      obj.read {|chunk| $stdout.write chunk }
    end
  end

  desc 'Faux tail the S3 logs with an optional line limit'
  task :tail, [:limit] do |t, args|
    logs.reverse_each.take(args.limit ? args.limit.to_i : 20).reverse_each do |obj|
      obj.read {|chunk| $stdout.write chunk }
    end
  end

  def bucket
    b = JEKYLL_CONFIGURATION['aws']['bucket']
    AWS::S3.new.buckets[b]
  end

  def logs
    b = JEKYLL_CONFIGURATION['aws']['logs']
    AWS::S3.new.buckets[b].objects.with_prefix("logs/")
  end

  def write_object(obj, path)
    obj.write path, content_type: Rack::Mime.mime_type(path.extname)
    puts "- Object written: #{obj.public_url}"
  end
end

