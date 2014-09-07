require 'rubygems'
require 'rake'
require 'rdoc'
require 'date'
require 'yaml'

desc "Generate blog files"
task :build do
  system "bundle exec jekyll build"
end

desc "Generate and publish blog to gh-pages"
task :publish => [:build] do
  system "git branch -D gh-pages"
  system "git checkout -b gh-pages"
  system "git filter-branch --subdirectory-filter _site/ -f "
  system "git checkout source"
  system "git push --all origin"
  system "echo yolo"
end

task :default => :publish
