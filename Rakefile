require 'rubygems'
require 'rake'
require 'rdoc'
require 'date'
require 'yaml'
require 'tmpdir'

desc "Serve the site locally"
task :serve do
  system "bundle exec jekyll serve -w"
end

desc "Generate blog files"
task :build do
  system "bundle exec jekyll build"
end

desc "Generate and publish blog to gh-pages"
task :publish => [:build] do
  Dir.mktmpdir do |tmp|
    system "mv _site/* #{tmp}"
    system "git checkout -B gh-pages"
    system "rm -rf *"
    system "mv #{tmp}/* ."
    message = "Site updated at #{Time.now.utc}"
    system "git add ."
    system "git commit -am #{message.shellescape}"
    system "git push origin gh-pages --force"
    system "git checkout source"
    system "echo yolo"
  end
end

task :default => :publish
