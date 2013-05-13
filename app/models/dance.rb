require 'mongo'
require 'uri'

class Dance < ActiveRecord::Base
  attr_accessible :foreign_id, :title, :description
  belongs_to :user

  def sync data
  	collection = Dance.get_mongo_collection
  	if !self.foreign_id then
  		# if foreign_id not set yet, insert data and set the foreign_id
  		f_id = collection.insert({"data" => data}).to_s
  		self.foreign_id = f_id
      self.save
  	else
  		# if foreign_id is already set, update
  		collection.update({"_id" => self.foreign_id}, {"$data" => data})
  	end
  end

  def get_data
  	collection = Dance.get_mongo_collection
  	collection.find_one({"_id" => BSON::ObjectId(self.foreign_id)})
  end

  def self.get_mongo_collection
  	if ENV['MONGOHQ_URL'] then	# production
  		db = URI.parse(ENV['MONGOHQ_URL'])
  		db_name = db.path.gsub(/^\//, '')
  		collection_name = 'dancedata'
  		@@collection = Mongo::Connection.new(db.host, db.port).db(db_name)[collection_name]
  	else	# development
  		@@collection = Mongo::Connection.new('localhost').db('formitdb')['dancedata']
  	end

  	@@collection
  end
end