#!/usr/bin/env ruby

require 'csv'
require 'uri'
require 'aws/s3'
require 'open-uri'

class Article

  attr_reader :opts, :uuid, :published_at, :tags, :title, :author, :author_link, :essential, :summary, :url, :added_at, :image, :image_local, :youtube, :vimeo, :hnews

  def initialize opts={}
    @opts = opts
    @opts.keys.each do |k|
      instance_variable_set "@#{k}", @opts[k]
    end
  end

  class << self
    def process csv_string
      hashes      = csv_to_arr_of_hashes csv_string
      hashes.map{|hash| new hash }
    end

    def process_one tsv
      heads = %w(uuid published_at tags title author author_link summary url added_at image image_local youtube vimeo hnews)
      arr = [tsv.split("\t")]
      hash = arr.map{|row| h = Hash[heads.zip(row)]; h if h && h.any? }.compact[0]
      new hash
    end

    private

    def csv_to_arr_of_hashes csv_string
      csv = CSV.parse csv_string
      heads = csv.shift
      csv.map{|row| h = Hash[heads.zip(row)]; h if h && h.any? }.compact
    end
  end

  def published_date
    time_to_date published_at
  end

  def added_date
    time_to_date added_at
  end

  def order_date
    #published_date || added_date
    added_date
  end

  def host
    URI.parse(url).host.sub(/www\./,'')
  end

  def filename
    "#{slug}.md"
  end

  def slug
    "#{order_date}-#{slugify(title)}"
  end

  def image_filename name=nil
    name ||= image.split('/')[-1]
    "images/#{slug}/#{name}"
  end

  def image_local_filename
    image_filename image_local
  end

  private

  def time_to_date t
    t.to_s.split(' ')[0]
  end

  def slugify s
    s.gsub(/[^a-zA-Z0-9\-\ ]/,'').gsub(/ /,'-').downcase
  end
end

def present? s
  s && s != ''
end

def output_article a
  output = ""
  output += "---\n"
  output += "layout: \"post\"\n"
  output += "title: \"#{a.title}\"\n"
  output += "tags: [#{a.tags.downcase}]\n" if a.tags
  output += "original: \"#{a.url}\"\n"
  output += "image: \"#{a.image_filename}\"\n" if a.image
  output += "image: \"#{a.image_local_filename}\"\n" if a.image_local && a.image_local != ''
  output += "vimeo: \"#{a.vimeo}\"\n" if a.vimeo && a.vimeo != ''
  output += "youtube: \"#{a.youtube}\"\n" if a.youtube && a.youtube != ''
  output += "hnews: \"#{a.hnews}\"\n" if a.hnews
  output += "author: \"#{a.author}\"\n" if present? a.author
  output += "author_link: \"#{a.author_link}\"\n" if present? a.author_link
  #output += "image: \"#{a.image}\"\n" if a.image
  output += "---\n"
  output += "\n"
  output += "<blockquote>#{a.summary}</blockquote>\n"
  #output += "<p>#{a.author}</p>\n"
  output += "\n"
  output
end

#print "Processing csv..."
#articles = Article.process(File.read('articles.csv'))
#articles = articles.sort{|a,b| b.order_date.to_s <=> a.order_date.to_s }
#puts "done."

if ARGV[0]=='post'
  article = Article.process_one `pbpaste`
  File.open("_posts/#{article.filename}", 'w') do |f|
    f.puts output_article(article)
  end
  exit
end

if ARGV[0]=='image:upload'
  AWS::S3::Base.establish_connection!(
    :access_key_id     => ENV['AMAZON_ACCESS_KEY_ID'],
    :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
  )
  article = Article.process_one `pbpaste`
  if article.image
    print "Downloading #{article.image}..."
    file = open(article.image)
    puts "done."
  elsif article.image_local
    file = File.open(article.image_local)
  end

  if file
    bucket = 'thebuilding.io'
    print "Uploading #{article.image_filename}..."
    res = AWS::S3::S3Object.store(article.image_filename, file, bucket, access: :public_read)
    puts "done."
    puts res.inspect
  end
  exit
end

#if ARGV[0]=='--rm'
#  print "Removing posts..."
#  `rm _posts/*`
#  puts 'done.'
#end

# Generate top README
#print "Writing posts..."
#articles.each do |a|
#  File.open("_posts/#{a.filename}", 'w') do |f|
#    f.puts output_article a
#  end
#end
#puts "done."

