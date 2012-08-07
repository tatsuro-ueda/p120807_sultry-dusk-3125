# coding:utf-8

require 'sinatra'
require 'net/http'
require 'yajl'
require 'active_support/core_ext'
require 'mongoid'

host = 'pipes.yahoo.com'
path = '/pipes/pipe.run?_id=6adb7c2f4644af358fbe273293c80e43&_render=rss&tag=technology'

class RSS
  include Mongoid::Document
  field:title
  field:description
  field:link
  field:created_at, :type => DateTime, :default =>  lambda{Time.now}
end

Mongoid.configure do |conf|
  conf.master = Mongo::Connection.from_uri('mongodb://heroku_app6504948:p7iv4pqk08lsa63e5nsubck3uf@ds037047-a.mongolab.com:37047/heroku_app6504948').db('dbname')
  # conf.master = Mongo::Connection.new('localhost', 27017).db('mongoid-test')
end

xml = Net::HTTP.get(host, path)
h = Hash.from_xml(xml)['rss']['channel']['item']
h.each do |key|
  rss = RSS.new(:title => key['title'],
                :description => key['description'],
                :link => key['link'])
  puts rss.title
  rss.save
end

get '/' do
  xml.force_encoding 'utf-8'
  content_type 'application/json'
  Yajl::Encoder.encode(Hash.from_xml(xml))
end