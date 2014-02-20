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



